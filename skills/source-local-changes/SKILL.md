---
name: source-local-changes
description: "Reference for other skills, not run directly: how to read your uncommitted local changes in a git or svn working copy safely (detect, scope flags, change set, execution copy, untouched check)."
disable-model-invocation: true
---

# Source: your local changes (a git or svn working copy)

Used by `review` and any skill that needs what changed locally, before it is committed. No GitHub and no pull request: it works from `git` or `svn` on this machine. Read-only. It follows the standard source sections (see `review/references/engine.md`). It also covers one commit or a range from history.

## Detect

```bash
git --no-optional-locks -C <path> rev-parse --show-toplevel 2>&1
svn info <path> --show-item wc-root 2>&1
```

- git succeeds: VCS = git, root = the output.
- else svn succeeds: VCS = svn, root = the output.
- neither: report that the path is not inside a git or svn working copy, and stop.

If `<path>` is a file, run both commands on its parent directory and treat the file as an `--only` pathspec. When both commands succeed (an svn checkout inside a git repo, or the reverse), use the one whose root is closest to `<path>` and say which.

## Arguments

Optional `path` (default: current directory), at most one scope flag, and optionally `--only <path>...` to limit the change set to those paths (use it when a tree has unrelated untracked files).

A `path` that is a subdirectory and every `--only <path>` become pathspecs, made relative to `<root>` first (every command runs as `git --no-optional-locks -C <root>`): append `-- <paths>` to each git diff, status and ls-files command, and pass the paths to svn status and diff. `--staged` omits untracked files.

| Flag | git | svn |
|---|---|---|
| (none) | staged + unstaged + untracked vs HEAD | all modified/added/deleted + unversioned vs BASE |
| `--staged` | index vs HEAD only | does not exist: report and stop |
| `--unstaged` | worktree vs index (+ untracked) | does not exist: report and stop |
| `--base <ref>` | merge-base of `<ref>` and HEAD through the working tree (branch commits + local changes) | `<rev>` through the working copy |
| `--commit <id>` | that one commit | that one revision |
| `--range <a>..<b>` | the commits in the range (no working tree) | `<a>:<b>` |

## Collect: trust and base

Make one run directory with `mktemp -d <scratchpad>/review-XXXXXX` (or plain `mktemp -d` if the system prompt lists no scratchpad directory), call it `RUN`, and name it in the report. Never use the scratchpad directory itself as `RUN`, because the cleanup removes `RUN`.

**Trust:** changes in the working copy are trusted. `--commit`, `--range` and `--base` are trusted only if every commit in scope is authored by the configured user, or the user passed `--trust`; otherwise untrusted (see the engine's **Trust**). Read the authors with `git --no-optional-locks -C <root> log --format=%ae <scope>` where `<scope>` is `<id>^!` for `--commit`, `<a>..<b>` for `--range` and `<MB>..HEAD` for `--base`, and compare with `git config user.email`. Author emails can be forged, so this is a heuristic. For svn, `--commit` and `--range` are untrusted unless the user passed `--trust`.

**Base** (for the engine's "is this failure new?" re-run): the working copy and `--staged` use `HEAD`; `--unstaged` uses the index (copy the index file to `<RUN>/idx`, then `GIT_INDEX_FILE=<RUN>/idx git --no-optional-locks -C <root> write-tree` and export that tree); `--base <ref>` uses the merge-base SHA; `--commit <id>` uses `<id>^` (a root commit has none: report the base as none); `--range <a>..<b>` uses `<a>`; svn uses `svn export -r BASE`. Export it to `<RUN>/base-tree` the way **Execution copy** says.

## Collect

### git

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

### svn

```bash
svn info <root>
svn status <root>
svn diff <root>
```

Scope adjustments: `--base <rev>`: `svn diff -r <rev> <root>`.

Unversioned (`?`) files have no diff: treat as fully added, same skip rules as above. Conflicted (`C`) or missing (`!`) entries are findings in themselves - report them. Honor `svn:ignore` (already reflected in `svn status`).

### Both

If the change set is empty (no diff, no untracked files), there is nothing to review: the engine returns the three-line `NO CHANGES` report; name the scope you used.

### A commit or a range (`--commit`, `--range`)

The change set is history, not the working tree, so there are no untracked files and the working tree is not read.

- git: `git --no-optional-locks -C <root> show --stat --name-status <sha>` and `git --no-optional-locks -C <root> show <sha>`; or `git --no-optional-locks -C <root> diff --stat --name-status <a>..<b>` and `git --no-optional-locks -C <root> diff <a>..<b>`. Read files with `git --no-optional-locks -C <root> show <sha-or-b>:<path>`. Execution copy: export `<sha-or-b>` with a temporary index as in **Execution copy** below.
- svn: `svn diff -c <rev> <root>` or `svn diff -r <a>:<b> <root>`. Execution copy: `svn export -r <rev-or-b> <root> <RUN>/tree`.
- Untouched check: the usual one.

## Read

- git: the new version is the file in the working tree (with `--staged`: `git --no-optional-locks -C <root> show :<path>`, the index); the base is `git --no-optional-locks -C <root> show HEAD:<path>` (or `<MB>:<path>` with `--base`; with `--unstaged`: `git --no-optional-locks -C <root> show :<path>`, the index). History for context: `git --no-optional-locks -C <root> log -10 --oneline --no-decorate`.
- svn: the new version is the file in the working copy; the base is `svn cat -r BASE <path>`. History: `svn log <root> -l 10` (it may need authentication; if it fails, say so and go on).

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

(`--staged` and `--unstaged` get the index content by `write-tree` on a copy of the index file, `cp <git-dir>/index <RUN>/idx` then `GIT_INDEX_FILE=<RUN>/idx git --no-optional-locks -C <root> write-tree`, never on the real index: that would rewrite it and take `index.lock`. It adds only tree objects to the object store and fails on unmerged entries, which is then a finding in itself.) `--ignore-missing-args` keeps a tracked file that was deleted in the working tree from failing the copy, and `--copy-unsafe-links` turns file links that point outside the tree into plain copies (a link to a directory outside the tree, and a submodule, become empty directories), so nothing in the copy points back at the target. Whatever the way, delete every `.env*` file from the copy and from the base copy (they may hold real credentials; tests that need a fixture such as `.env.example` are noted under Verification Results). Never symlink anything back to the target (tests could write through it) and never link `.git`. Do not copy a `.venv` or `node_modules` either: an editable install in a copied venv still imports the original tree, so the tests would run the wrong code. Run tests with `PYTHONPATH=<RUN>/tree/src` (or the right root) and check that the module's `__file__` points into `<RUN>/tree`; if you cannot, note the tests that could not run under Verification Results. For an svn working copy: `svn export <root> <RUN>/tree` and copy the unversioned files over it. Remove `<RUN>` at the end.

## Untouched check

Before anything else record the state into a file in the run directory (`<RUN>/before.txt`, never into the conversation: `--ignored` lists `node_modules` and build output, which can be huge): git: `git --no-optional-locks -C <root> status --porcelain=v2 -z --ignored`, `git --no-optional-locks -C <root> rev-parse HEAD`, `git --no-optional-locks -C <root> stash list` and `git --no-optional-locks -C <root> for-each-ref`, appended to the file; svn: `svn status <root>`. At the end write the same to `<RUN>/after.txt` and `cmp` the two files, and look at a diff only if they differ. Compare: a difference the review could have caused is a CRITICAL process finding (the user may be editing at the same time, so look at what changed before blaming the review).

## Restrictions

The working copy is the user's work in progress. Never alter it or its version-control state: git: no stash, reset, revert, clean, checkout, add, commit, amend or push; svn: no add, rm, revert, update, commit, cleanup, switch or propset.
