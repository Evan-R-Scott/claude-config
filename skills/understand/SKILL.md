---
name: understand
description: Explain one or more files from a local repo step by step, with context pulled from the repo's CLAUDE.md. Usage: /understand <repo-name> <file1> [file2] ... OR /understand <github-pr-url>
metadata:
  version: "1.1.0"
  category: learning
  tags: ["learning", "explanation", "onboarding", "files"]
compatibility:
  universal: true
---

# Understand Files

This skill explains files from a local repository to help onboard new team members.
Repos live at `<repos-root>/<repo-name>`. Use the repos root the user names; if they name none, use the parent of the current directory, and confirm `<repos-root>/<repo-name>` exists before continuing.

## Instructions

The user invokes this skill in one of two ways:

**Mode A - explicit files:**
```
/understand <repo-name> <file1> [file2] [file3] ...
```

**Mode B - PR URL:**
```
/understand <github-pr-url>
```

Parse the args to determine which mode applies. If the first token starts with `https://github.com`, it is a PR URL - use Mode B. Otherwise use Mode A.

---

## Mode A: Explicit files

Parse the args to extract the repo name (first token) and the list of files (all remaining tokens). Then follow Steps 1-3 below.

---

## Mode B: PR URL

When a GitHub PR URL is provided (format: `https://github.com/<owner>/<repo>/pull/<number>`):

### Step B1: Fetch PR metadata and diff

Run in one call:
```bash
gh pr view <url> --json number,title,body,headRefName,baseRefName,files
```

Then fetch the full diff:
```bash
gh api repos/<owner>/<repo>/pulls/<number> -H "Accept: application/vnd.github.v3.diff" 2>&1
```

Extract:
- `headRefName` - the PR branch
- `baseRefName` - the target branch
- `files` - list of changed file paths
- The diff itself - what lines were added/removed in each file

### Step B2: Derive the repo name

Map the GitHub repo name to the local clone directory. The local clone is at `<repos-root>/<repo-name>` where `<repo-name>` is the last path segment of the GitHub repo URL (e.g. `example-org/example-repo` → `example-repo`).

### Step B3: Check out the PR branch

```bash
cd <repos-root>/<repo-name>
git fetch origin <headRefName>
git checkout <headRefName>
git pull --ff-only
```

If the checkout fails, report the error and stop.

### Step B4: Identify files to explain

Use the `files` list from the PR metadata. These are the files changed by this PR. Explain all of them unless there are more than 8 - in that case, list them all and ask the user which ones to focus on.

### Step B5: Proceed to Step 1 (load repo context) and Step 3 (explain files)

Use the PR diff as additional context during the explanation. For each file, after the normal section-by-section breakdown, add a **"What changed in this PR"** section that:
- Summarises what lines were added, removed, or modified (quoting key hunks from the diff)
- Explains WHY each change was made - the problem it solves, the bug it fixes, the capability it adds
- If the PR description explains the motivation, incorporate that context

---

## Step 1: Load repo context

The repo root is `<repos-root>/<repo-name>`.

Check if a `CLAUDE.md` exists at the repo root:
```bash
cat <repos-root>/<repo-name>/CLAUDE.md
```

If it exists, read it fully to understand:
- What the repo does and its overall purpose
- Directory structure and conventions
- Key concepts, cluster names, terminology specific to this repo

If no CLAUDE.md exists, do a quick structural scan to orient yourself:
```bash
ls <repos-root>/<repo-name>/
find <repos-root>/<repo-name> -maxdepth 2 -type d | sort | head -40
```

Do not summarize the CLAUDE.md back to the user - just use it silently as context.

### Step 2: Locate each file

For each filename the user provided, find it under the repo root. The user may provide:
- A path relative to the repo root (e.g. `packages/node-exporter/node-exporter-daemonset.yaml`)
- Just a filename with no path (e.g. `node-exporter-daemonset.yaml`)

If a relative path was given, read it directly:
```
<repos-root>/<repo-name>/<relative-path>
```

If only a filename was given, search for it:
```bash
find <repos-root>/<repo-name> -name "<filename>" -not -path "*/.git/*" | sort
```

If multiple matches are found for a bare filename, list them and ask the user which one they meant before proceeding.

### Step 3: Explain each file

For each file, produce a thorough explanation aimed at an intern with general software knowledge but no familiarity with this specific codebase. Go file by file in the order the user listed them.

Structure each file's explanation as follows:

**Header**: State the filename as a markdown link (relative path from repo root) and one sentence on what this file is at the highest level.

**Section-by-section breakdown**: Walk through the file top to bottom. For each logical section or block:
- Quote or reference the relevant lines/keys
- Explain WHAT it does in plain language
- Explain WHY it exists - the motivation, the problem it solves, or the constraint it encodes
- If a section connects to another file or concept in the repo, say so explicitly using the CLAUDE.md context you loaded

Use plain language. Avoid jargon without defining it first. If a term (e.g. DaemonSet, ServiceMonitor, remote_write) is domain-specific, explain it briefly the first time it appears.

**Summary**: End each file with 2–3 sentences on how this file fits into the bigger picture - what breaks if it's missing, what it depends on, what depends on it.

### Rules

- Go file by file. Do not merge explanations across files.
- Do not just describe what lines say - explain the reasoning and context behind them.
- If the file references another file in the repo that is highly relevant, mention it with a relative path link.
- If the file is generated or templated (e.g. a Helm template), note that and explain what it renders into.
- Keep a consistent tone: knowledgeable but approachable, like a senior engineer walking a new hire through the code.
