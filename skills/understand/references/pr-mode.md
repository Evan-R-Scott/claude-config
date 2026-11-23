# Mode B: explain the files of a pull request

Read in full when the first argument is a PR URL. It replaces Mode A's argument parsing and reads the files at the PR head; Steps 1 and 3 of `SKILL.md` then apply as written, with `ROOT` set in step B2.

When a PR URL is provided (`https://<host>/<owner>/<repo>/pull/<number>`). Never check out a branch in the user's clone: it can fail on a dirty tree and it moves their work.

### Step B1: Fetch PR metadata and diff

```bash
gh pr view <url> --json number,title,body,headRefName,headRefOid,baseRefName,changedFiles,files --jq '{number,title,body:.body[:3000],headRefName,headRefOid,baseRefName,changedFiles,files:[.files[].path]}'
gh pr diff <url>
```

Hold the head commit (`headRefOid`), the changed file list and the diff. If `gh` fails (auth, no access), show the raw error and stop.

### Step B2: Find the files at the PR head

Look for a local clone: `<repos-root>/<repo>` (last segment of `<owner>/<repo>`), or the current directory. Accept it only if `git remote -v` contains `<host>/<owner>/<repo>`. Then:

- If the clone's `git rev-parse HEAD` equals `headRefOid`, read files from the working tree. That clone is `ROOT` (CLAUDE.md and file links use it).
- Otherwise do not switch branches. Read each file at the PR head with `gh api --hostname <host> "repos/<owner>/<repo>/contents/<path>?ref=<headRefOid>" -H "Accept: application/vnd.github.raw"` (quote the URL: `?` is a glob character in zsh), and take CLAUDE.md or AGENTS.md from the same API at that ref (if the API has none there, a copy from the clone's current checkout is the base branch's, possibly stale: say so). Reading a fork PR's head commit through the base repo's API works because GitHub exposes fork commits there; if it fails (for example the fork was deleted), say the head cannot be read and explain from the diff alone. With no local clone, `ROOT` is unset: take CLAUDE.md from the API and link files by their repo-relative path only; say so and explain from the diff and API content alone.

### Step B3: Identify files to explain

Use the `files` list from the PR metadata (it holds at most 100 paths: compare it with `changedFiles`, and for a larger pull request say so and ask which area to explain). These are the files changed by this PR. Explain all of them unless there are more than 8 - in that case, list them all and ask the user which ones to focus on.

### Step B4: Proceed to Step 1 (load repo context) and Step 3 (explain files)

This mode shows the diff and files only. For the CI result, review threads and conversation comments use the `pr-info` skill.

Use the PR diff as additional context during the explanation. For each file, after the normal section-by-section breakdown, add a **"What changed in this PR"** section (for a file the PR adds, say "new file in this PR" and skip the section: it would repeat the breakdown) that:
- Summarises what lines were added, removed, or modified (quoting key hunks from the diff)
- Explains WHY each change was made - the problem it solves, the bug it fixes, the capability it adds
- If the PR description explains the motivation, incorporate that context

---
