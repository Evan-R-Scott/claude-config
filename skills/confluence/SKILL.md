---
name: confluence
description: "Read, search, edit or create pages on any Confluence Cloud site you have access to, safely: reads with acli, edits through the REST API with a diff, your confirmation, a backup and a post-write check. Use when given a Confluence URL or page ID, or asked to read, find, update or create a page. Usage: /confluence <url | page id | request>"
metadata:
  version: "2.0.0"
  category: documentation
  tags: ["confluence", "atlassian", "wiki", "docs"]
compatibility:
  universal: true
---

# Confluence

Reads go through Atlassian's official `acli` when it is installed and logged in. Search, edits and creation use the Confluence Cloud REST API, because `acli` only has `confluence page view`. No site, space or page is hardcoded: everything comes from the URL or the request.

## Setup (once per machine)

- Reads: `acli confluence auth login --web`, or `acli confluence auth login --site <site>.atlassian.net --email <email> --token < token.txt` (the token file is read from stdin so it never appears on a command line or in history; token from https://id.atlassian.com/manage-profile/security/api-tokens, without scopes).
- Search, edit, create: set three environment variables, for example in the file your shell profile loads (such as `~/.zshrc.local`), with `chmod 600` on that file. `acli confluence auth` is a separate login from `acli jira auth`:
  `export ATLASSIAN_SITE=https://<site>.atlassian.net`, `export ATLASSIAN_EMAIL=<email>`, `export ATLASSIAN_API_TOKEN=<API token>`.
  Claude's shell must load them: put them in a file read by login shells (`~/.zprofile`, `~/.zshenv`, or a file those source), not only `.zshrc`. Check with `[ -n "$ATLASSIAN_API_TOKEN" ] && echo set` (never echo the value).
- Fallback if the variables are unset: `~/.atlassian/confluence.properties` with `server=`, `user=`, `password=` (the token), one per line, `chmod 600`.
- With neither, offer read-only help with `acli`, and show this setup for anything else. Never ask the user to paste a token into the conversation.

## Credentials in commands

Define these helpers in every Bash call (shell state does not persist); they read the environment first, then the file, and pass the credentials to `curl` on stdin, so the token never appears in the process list or in output:

```bash
p=~/.atlassian/confluence.properties
get(){ [ -f "$p" ] && grep -E "^$1=" "$p" | head -1 | cut -d= -f2-; }
S=${ATLASSIAN_SITE:-$(get server)}; S=${S%/}; S=${S%/wiki}; case $S in http*) ;; *) S=https://$S;; esac
SCRATCH=<the scratchpad directory path from the system prompt: write the real path here>
[ -f "$p" ] && [ "$(stat -c %a "$p")" != 600 ] && echo "warning: $p is not mode 600, run chmod 600 on it" >&2
cf(){ printf 'user = "%s:%s"\n' "${ATLASSIAN_EMAIL:-$(get user)}" "${ATLASSIAN_API_TOKEN:-$(get password)}" | curl -sS -K - -H 'Accept: application/json' -w '\nHTTP_STATUS:%{http_code}\n' "$@"; }
```

`cf` ends its output with an `HTTP_STATUS:<code>` line (it is the last line of the output, or the only output when `-o` writes the body to a file). Always read it: only a 2xx status means the body is the page. For any other status stop and show the one-line status and reason, delete the file `-o` wrote (it holds an error body, not the page), and never continue an edit on it. Never print, echo, log or write the email or token (not even `env` or `set` output); show the file only with values redacted. The URL's host must equal the host in `$S`; if a user gives a page on another site, stop and say credentials for that site are needed (credentials are never sent to another host). If calls return 401 or 403 while the token is valid, it may be a scoped token: use the gateway `https://api.atlassian.com/ex/confluence/<cloudId>` in place of `$S` (the cloud id is at `$S/_edge/tenant_info`), and say so if neither works.

## Resolve the target

- URL: the page id is the number after `/pages/` (also `/pages/edit-v2/<id>`, `/pages/<id>/Title`); ignore query strings. Short links (`/x/AbCd`): `cf -L` the link and read the id from the final URL.
- Title or keywords: search with CQL (below), then confirm the hit if more than one is plausible.

## Read

```bash
# preferred when acli is logged in
acli confluence page view --id <ID> --body-format view
# REST: metadata and body (use storage for anything you may edit)
cf "$S/wiki/api/v2/pages/<ID>?body-format=storage" -o "$SCRATCH/page-<ID>.json"
cf -G "$S/wiki/rest/api/search" --data-urlencode 'cql=space = "<KEY>" AND type = page AND title ~ "<text>"' --data-urlencode limit=10
cf "$S/wiki/api/v2/pages/<ID>/children?limit=50"
```

The body is XHTML "storage format": for a summary, strip tags with a small `python3 -I` snippet and report the title, space, version and the content that matters; never dump raw storage HTML at the user. For attachments, labels or comments use `$S/wiki/api/v2/pages/<ID>/attachments`, `/labels`, `/footer-comments` the same way, only when asked.

## Edit and create (read the reference first)

Every write (editing, creating, restoring a backup) follows `~/.claude/skills/confluence/references/edit-create.md`. **Before the first write command, read that file in full**: it holds the fetch, minimal-change, diff, confirmation, backup, version-conflict and read-back steps, and the create flow. Do not edit or create a page from memory. Reading, searching and listing need nothing from it.

## Document-type skills

Shared storage-format snippets (panels, tables, status lozenges, code blocks, steps) are in `~/.claude/skills/confluence/references/storage-snippets.md`; read it when writing a new body.

This skill is only the mechanics (read, search, edit, create). Content rules for a particular kind of document live in separate `doc-*` skills that publish through this one. Before drafting a new page or a rewrite, check the installed skills for one that matches the page's purpose and follow it for structure: `doc-design` for high-level system or architecture designs, `doc-runbook` for step-by-step runbooks and how-to docs (these also write Markdown files; `doc-render` handles both destinations). If none matches, write the page plainly; do not apply a template meant for another page type.

## Rules

- Writes (PUT, POST, DELETE) always need the user's confirmation of the shown change. Never delete or archive a page unless explicitly asked, and then confirm the page title first.
- Do not change permissions, restrictions, labels or page moves unless explicitly asked.
- Keep terminal output short: page title, version, and the result of the action.
- Errors: show the one-line HTTP status and reason (401 credentials, 403 no access, 404 wrong id or no access, 409 version conflict) and stop.
