---
name: source-local-changes
description: "Reference for other skills, not run directly: how to read your uncommitted local changes in a git or svn working copy safely (detect, scope flags, change set, execution copy, untouched check)."
disable-model-invocation: true
---

# Source: your local changes (a git or svn working copy)

Used by `review` and any skill that needs what changed locally, before it is committed. No GitHub and no pull request: it works from `git` (or `svn`, see below) on this machine. Read-only. It follows the standard source sections (see `review/references/engine.md`). It also covers one commit or a range from history. Everything below is for git; for an svn working copy read `~/.claude/skills/source-local-changes/references/svn.md` in full instead.

## Detect

```bash
git --no-optional-locks -C <path> rev-parse --show-toplevel 2>&1
```

If it succeeds the root is the output. If it fails try `svn info <path> --show-item wc-root`: if that succeeds read `references/svn.md`; if neither works, report that the path is not inside a git or svn working copy, and stop. If `<path>` is a file, run them on its parent directory and treat the file as an `--only` pathspec. When both succeed (an svn checkout inside a git repo, or the reverse), use the one whose root is closest to `<path>` and say which.

## Arguments

Optional `path` (default: current directory), at most one scope flag, and optionally `--only <path>...` to limit the change set to those paths (use it when a tree has unrelated untracked files).

A `path` that is a subdirectory and every `--only <path>` become pathspecs, made relative to `<root>` first (every command runs as `git --no-optional-locks -C <root>`): append `-- <paths>` to each git diff, status and ls-files command. `--staged` omits untracked files.

| Flag | Scope |
|---|---|
| (none) | staged + unstaged + untracked vs HEAD |
| `--staged` | index vs HEAD only |
| `--unstaged` | worktree vs index (+ untracked) |
| `--base <ref>` | merge-base of `<ref>` and HEAD through the working tree (branch commits + local changes) |
| `--commit <id>` | that one commit |
| `--range <a>..<b>` | the commits in the range (no working tree) |

## Collect: trust and base

Make one run directory with `mktemp -d <scratchpad>/review-XXXXXX` (or plain `mktemp -d` if the system prompt lists no scratchpad directory), call it `RUN`, and name it in the report. Never use the scratchpad directory itself as `RUN`, because the cleanup removes `RUN`.

**Trust:** changes in the working copy are trusted when the repository's history shows the configured user among its authors (`git --no-optional-locks -C <root> log -20 --format=%ae`); in a clone whose recent commits are all by others, untracked or modified files still count as the user's own edits only if the user says so, so treat the change as untrusted unless the user passed `--trust` or confirms. `--commit`, `--range` and `--base` are trusted only if every commit in scope is authored by the configured user, or the user passed `--trust`; otherwise untrusted (see the engine's **Trust**). Read the authors with `git --no-optional-locks -C <root> log --format=%ae <scope>` where `<scope>` is `<id>^!` for `--commit`, `<a>..<b>` for `--range` and `<MB>..HEAD` for `--base`, and compare with `git -C <root> config user.email`. Author emails can be forged, so this is a heuristic.

**Base** (for the engine's "is this failure new?" re-run): the working copy and `--staged` use `HEAD` (a repository with no commit yet has none: report the base as none); `--unstaged` uses the index; `--base <ref>` uses the merge-base SHA; `--commit <id>` uses `<id>^` (a root commit has none: report the base as none); `--range <a>..<b>` uses `<a>`; export it to `<RUN>/base-tree` the way **Execution copy** says.

## Collect

### Working copy (git)

```bash
git --no-optional-locks -C <root> branch --show-current
git --no-optional-locks -C <root> status --short --branch
git --no-optional-locks -C <root> diff HEAD --stat
git --no-optional-locks -C <root> diff HEAD --name-status
git --no-optional-locks -C <root> ls-files --others --exclude-standard
```

Scope adjustments:
- `--staged`: use `git diff --cached` in place of `git diff HEAD`.
- `--unstaged`: use `git diff` (no ref).
- `--base <ref>`: `git merge-base <ref> HEAD` (call the printed SHA `<MB>`) then `git diff <MB>` (compares base to the working tree, so it includes commits and local edits). Also `git log <MB>..HEAD --oneline --no-decorate`. With `--base`, replace `HEAD` with the SHA that `git merge-base` printed in every command above. Shell variables do not persist between Bash calls, so record the SHA and paste it into each command.

Untracked files have no diff: treat each as a fully added file. Skip binaries, build output, and anything large or generated (note what was skipped). If HEAD does not exist (fresh repo), diff against the empty tree: `git diff $(git hash-object -t tree /dev/null)`.

Capture the full diff:

```bash
git --no-optional-locks -C <root> diff HEAD
```

### Both

If the change set is empty (no diff, no untracked files), there is nothing to review: the engine returns the three-line `NO CHANGES` report; name the scope you used.

### A commit or a range (`--commit`, `--range`)

The change set is history, not the working tree, so there are no untracked files and the working tree is not read.

- `git --no-optional-locks -C <root> show --stat --name-status <sha>` and `git --no-optional-locks -C <root> show <sha>`; or `git --no-optional-locks -C <root> diff --stat --name-status <a>..<b>` and `git --no-optional-locks -C <root> diff <a>..<b>`. Read files with `git --no-optional-locks -C <root> show <sha-or-b>:<path>`. Execution copy: export `<sha-or-b>` with a temporary index as in **Execution copy** below.
- Untouched check: the usual one.

## Read

- The new version is the file in the working tree (with `--staged`: `git --no-optional-locks -C <root> show :<path>`, the index); the base is `git --no-optional-locks -C <root> show HEAD:<path>` (or `<MB>:<path>` with `--base`; with `--unstaged`: `git --no-optional-locks -C <root> show :<path>`, the index). History for context: `git --no-optional-locks -C <root> log -10 --oneline --no-decorate`.

## Execution copy

Working copy (no scope flag, `--unstaged`, `--base`): copy exactly the files that are tracked or untracked and not ignored:

```bash
mkdir -p <RUN>/tree
git --no-optional-locks -C <root> ls-files -co --exclude-standard -z | rsync -a --copy-unsafe-links --ignore-missing-args --from0 --files-from=- <root>/ <RUN>/tree/
```

`--staged`, `--commit` and `--range` run on the content of that index or commit, not the working tree: export it with a temporary index, which ignores `.gitattributes` export rules and never touches the real index:

```bash
GIT_INDEX_FILE=<RUN>/idx git --no-optional-locks -C <root> read-tree <sha-or-tree>
GIT_INDEX_FILE=<RUN>/idx git --no-optional-locks -C <root> checkout-index -a --prefix=<RUN>/tree/
```

The index content (`--staged` for the new version, `--unstaged` for the base) comes from a copy of the index file, exported with the same `checkout-index`, never from the real index (reading it can rewrite it and take `index.lock`) and without `write-tree` (which would add objects to the user's repository):

```bash
cp "$(git --no-optional-locks -C <root> rev-parse --path-format=absolute --git-path index)" <RUN>/idx
GIT_INDEX_FILE=<RUN>/idx git --no-optional-locks -C <root> checkout-index -a --prefix=<RUN>/tree/        # --staged: the staged content
GIT_INDEX_FILE=<RUN>/idx git --no-optional-locks -C <root> checkout-index -a --prefix=<RUN>/base-tree/   # --unstaged: the base
```

The `HEAD` base (working copy and `--staged`) uses a temporary index the same way: `GIT_INDEX_FILE=<RUN>/idx-head git --no-optional-locks -C <root> read-tree HEAD`, then `checkout-index -a --prefix=<RUN>/base-tree/` (if `read-tree HEAD` fails with "Not a valid object name HEAD" there is no commit yet: the base is none). `checkout-index` fails on unmerged entries, which is a finding in itself.

For a large repository or a monorepo copy only the packages that contain changed files, plus the shared configuration they need (root manifest, lockfile, tooling config), not the whole tree; say what you left out. Submodule contents and LFS objects are not in the copy (a submodule becomes an empty directory, an LFS file stays a pointer): a check that fails only because of that is a Note in Verification Results, not a finding and not an INCOMPLETE trigger.

## Untouched check

Before anything else record the state into a file in the run directory (`<RUN>/before.txt`, never into the conversation: `--ignored` lists `node_modules` and build output, which can be huge): git: `git --no-optional-locks -C <root> status --porcelain=v2 -z --ignored`, `git --no-optional-locks -C <root> rev-parse HEAD`, `git --no-optional-locks -C <root> stash list` and `git --no-optional-locks -C <root> for-each-ref`, appended to the file. At the end write the same to `<RUN>/after.txt` and `cmp` the two files, and look at a diff only if they differ. Compare: a difference the review could have caused is a CRITICAL process finding (the user may be editing at the same time, so look at what changed before blaming the review).

## Restrictions

The working copy is the user's work in progress. Never alter it or its version-control state: git: no stash, reset, revert, clean, checkout, add, commit, amend or push.
