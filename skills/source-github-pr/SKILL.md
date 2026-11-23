---
name: source-github-pr
description: "Reference for other skills, not run directly: how to read a GitHub pull request safely (metadata, comments, diff, an exported tree of the head in a scratch clone) and how to post a review on it."
disable-model-invocation: true
---

# Source: GitHub pull request

Used by `review` and any skill that needs a pull request's content. It works from a scratch clone, so the user's own clone and branch are never used or touched. It follows the standard source sections (see `review/references/engine.md`) and also has a post procedure in `post.md`.

## Detect

The argument is a URL like `https://<host>/<owner>/<repo>/pull/<number>` (`github.com` or any GitHub Enterprise host `gh` is logged in to).

## Arguments

Extract `<host>`, `<owner>/<repo>` and `<number>` from the URL. For a host other than github.com add `--hostname <host>` to every `gh api` command below and clone with `gh repo clone <host>/<owner>/<repo>`. Optional `--trust` (see **Collect: trust**).

## Collect: metadata

```bash
gh pr view <url> --json number,title,state,author,headRefName,headRefOid,baseRefName,reviewDecision,files,commits,isCrossRepository
gh pr view <url> --json body,reviews,comments --jq '{body: .body[:3000], reviews: [.reviews[] | {author: .author.login, state, body: .body[:500]}], comments: [.comments[] | {author: .author.login, body: .body[:500]}]}'
gh api repos/<owner>/<repo>/pulls/<number> --jq '.author_association, .base.sha'
```

The third command gives the author's association (`gh pr view` has no field for it) and the base commit. Bot pull requests can have 30 KB bodies and long review bodies, so the second command cuts them. `files`, `reviews` and `comments` are capped: for a bigger pull request use `gh api --paginate repos/<owner>/<repo>/pulls/<number>/files` (and `/reviews`, `/comments`).

Hold: `headRefName`, `headRefOid`, `baseRefName`, `isCrossRepository`, `author.is_bot`, `author_association`, the base sha, `state`, `title`, `body`, `reviews`, `comments`, `reviewDecision` (an empty string means none), `files`. If MERGED or CLOSED, flag it in the report and review anyway (you cannot ask).

## Collect: trust

The PR is **trusted** if the user passed `--trust`, or if `isCrossRepository` is false (the branch lives in the repository itself, which needs write access) and either `author_association` is OWNER, MEMBER or COLLABORATOR or the author is a bot or GitHub App (`author.is_bot`, for example Dependabot). For a bot's dependency bump, install wheels only (`pip --only-binary :all:`, `npm --ignore-scripts`) and do not run it at all if the network cannot be cut when it must be. Otherwise it is **untrusted**: the engine runs none of its code (see the engine's **Trust**). Record which, and why.

## Collect: inline comments

```bash
gh api --paginate repos/<owner>/<repo>/pulls/<number>/comments
```

Each has: `id`, `path`, `line`/`original_line`, `body`, `user.login`, `diff_hunk`.

## Collect: the scratch clone

Make one run directory with `mktemp -d <scratchpad>/review-XXXXXX` (or plain `mktemp -d` if the system prompt lists no scratchpad directory), call it `RUN`, and name it in the report. Never use the scratchpad directory itself as `RUN`, because the cleanup removes `RUN`. Do not use `--filter=blob:none`: exporting from a lazy clone fetches every blob in its own round trip and takes minutes. Then:

```bash
gh repo clone <host>/<owner>/<repo> <RUN>/repo -- --no-checkout --single-branch --branch <baseRefName>
git -C <RUN>/repo fetch origin pull/<number>/head
git -C <RUN>/repo rev-parse FETCH_HEAD
```

`rev-parse FETCH_HEAD` (run straight after the pull-head fetch, before any other fetch, because every fetch overwrites `FETCH_HEAD`; or use `git rev-parse <headRefOid>^{commit}`) must equal `headRefOid`; if the author pushed in between, re-read the metadata and start over with the new commit. If the clone or fetch fails, report the exact error and stop, with one exception: for a MERGED or CLOSED PR whose base branch was deleted (common for stacked PRs; the error says the remote branch was not found), clone the default branch instead (`gh repo clone <host>/<owner>/<repo> <RUN>/repo -- --no-checkout --single-branch`), then `git -C <RUN>/repo fetch origin pull/<number>/head`, run `git -C <RUN>/repo rev-parse FETCH_HEAD` and compare it with `headRefOid`, and only then `git -C <RUN>/repo fetch origin <base-sha>` (which overwrites `FETCH_HEAD`), and say so in the report.

## Collect: the diff

```bash
gh pr diff <url>
gh pr view <url> --json commits
```

`gh pr diff` works for open, closed and merged pull requests. If it fails on a very large pull request (HTTP 406), use `git -C <RUN>/repo diff <base-sha>...<headRefOid>`. Note the commits reviewed.

## Collect: CI and earlier rounds

```bash
gh pr checks <url> 2>&1
```

A non-zero exit (no checks reported, or failing checks) is a CI result, not an error. Report CI as Pass / Fail / Pending / N/A, and remember that CI does not guarantee correctness. If earlier reviews or inline comments exist and new commits were pushed since, say so in the report (the user can run `--recheck`). For a re-check, the earlier findings are those in the report file or, if it is gone, the comments and reviews written by the current `gh` user (`gh api user --jq .login`).

## Execution copy (also where to read the files)

First run `git -C <RUN>/repo merge-base <headRefOid> <base-sha>` and note the SHA (`<MB>`; when the merge-base printed equals `headRefOid` (the head is already contained in the base, as in a merged PR), use the parent of the PR's first commit: `git -C <RUN>/repo rev-parse <first-commit-oid>^` with the oid from the `commits` metadata). Each Bash call is a separate shell, and zsh does not word-split variables, so write every command out literally with the SHAs pasted in; do not loop over unquoted variables. Then export the head and the base without applying the PR's `.gitattributes` (`git archive` would honor `export-ignore` and `export-subst`, which lets a PR hide files), using a temporary index:

```bash
GIT_INDEX_FILE=<RUN>/idx-head git -C <RUN>/repo read-tree <headRefOid>
GIT_INDEX_FILE=<RUN>/idx-head git -C <RUN>/repo checkout-index -a --prefix=<RUN>/tree/
GIT_INDEX_FILE=<RUN>/idx-base git -C <RUN>/repo read-tree <MB>
GIT_INDEX_FILE=<RUN>/idx-base git -C <RUN>/repo checkout-index -a --prefix=<RUN>/base-tree/
```

Check, for each of the two trees, that the extracted files match the tree object, leaving out submodule entries (`checkout-index` only makes an empty directory for them). Use NUL-separated lists, so names with spaces, tabs or non-ASCII characters do not give a false mismatch (shown for the head; do the same for the base with `<MB>` and `<RUN>/base-tree`):

```bash
git -C <RUN>/repo ls-tree -r -z <headRefOid> | grep -zv '^160000 ' | cut -z -f2- | LC_ALL=C sort -z > <RUN>/want.lst
find <RUN>/tree \( -type f -o -type l \) -printf '%P\0' | LC_ALL=C sort -z > <RUN>/have.lst
cmp <RUN>/want.lst <RUN>/have.lst
```

A difference means the export is incomplete: stop and report the error; do not review a partial tree. Then list the symlinks the PR adds or changes (`find <RUN>/tree -type l`, compared with the base). A PR's symlinks are real symlinks: never Read or run through one whose target resolves outside the tree (for example `-> /etc/hostname` or `-> ~/.config/gh/hosts.yml`). Report such a link as a Security finding and show the link's target string (it is not file content); links inside the tree, such as `../shared` in a monorepo, are fine. Delete every `.env*` file from both trees: `find <RUN>/tree <RUN>/base-tree -type f -name '.env*' -delete`. `<RUN>/tree` is the execution copy and the place to read new files; `<RUN>/base-tree` (built from the merge-base `<MB>`, so a base branch that moved on does not skew it) is the base for the engine's "is this failure new?" re-run. Put the reviewed SHA in the report. At the end remove `<RUN>` (Go's module cache is read-only: run `chmod -R u+w <RUN>` first).

## Read

The new version of a file is in `<RUN>/tree`; the base is in `<RUN>/base-tree`. For a grep over the new code use `<RUN>/tree`.

## Untouched check

The user's clone is not used, so there is nothing to compare. Do not run any command in the user's working directory except the `gh` calls above.

## Restrictions

Never alter the user's checked-out branch or working tree, never push, commit or amend. Never post except by the `post.md` procedure and only after explicit approval.

## Post

Never yours. The caller posts after the user approves; the rules are in `post.md` next to this file.

## Errors

If `gh` errors (auth, private repo, rate limit), surface the raw error and stop.
