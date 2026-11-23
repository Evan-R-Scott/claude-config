---
name: source-paths
description: "Reference for other skills, not run directly: how to read files or folders as they are, with no version control involved (documents, plans, configs, scripts)."
disable-model-invocation: true
---

# Source: files or folders as they are

Used by `review` and any skill that needs named files rather than a change. It follows the standard source sections (see `review/references/engine.md`).

## Detect

The caller names the paths explicitly (for example `--files <path>...`); nothing is detected.

## Arguments

One or more files or folders. Optionally `--base-dir <dir>`: a checkout onto which a `.patch` or `.diff` file is applied (see Collect).

## Collect

- Expand each path: a file is reviewed whole; a folder is walked (skip `.git`, `.svn`, `node_modules`, `.venv`, build output, binaries, and generated files; say what you skipped).
- A `.patch` or `.diff` file (or a diff pasted into the conversation, which the caller saves to a file first) is a change set: read the patch itself. If a checkout is named too (`--base-dir <dir>`), copy it to the execution copy (`rsync -a --copy-unsafe-links --exclude=.git`) and apply the patch there (`git apply --check`, then `git apply`) so the changed files can be read and tested whole; otherwise say it was not applied and nothing was run.
- Infer what each file is for from its content, its neighbors and any README. State the inferred purpose in the Summary. You cannot ask.

## Trust and run directory

Make one run directory with `mktemp -d <scratchpad>/review-XXXXXX` (or plain `mktemp -d` if the system prompt lists no scratchpad directory), call it `RUN`, and name it in the report. Never use the scratchpad directory itself as `RUN`, because the cleanup removes `RUN`. Files the user wrote or owns are trusted. A downloaded or emailed script, a patch from outside, or anything of unknown origin is untrusted unless the user passed `--trust` (see the engine's **Trust**). When unsure, treat it as untrusted. There is no base: a check failure is reported as observed.

## Read

Read each file directly. If the paths are inside a git or svn working copy, still review the files as they are; use the history only for context (`git --no-optional-locks log -5 -- <path>`).

## Execution copy

Copy the paths to `<RUN>/tree/` with `rsync -a --copy-unsafe-links --relative --exclude=.git --exclude=node_modules --exclude=.venv <parent>/./<path1> <parent>/./<path2> ... <RUN>/tree/` (`<parent>` is their common parent directory, the `/./` keeps each path's layout relative to it so same-named files from different folders do not collide; `--copy-unsafe-links` turns a symlink pointing outside the copy into a real file, so a test cannot write through it into the original), and run checks there. For the project context (E1) look for `CLAUDE.md` and config files in the nearest ancestors of that parent; plain files have no repository root. Remove it at the end.

## Untouched check

Before anything else record a listing with sizes and modification times of every file you will read into `<RUN>/before.txt` (never into the conversation: a folder walk can be thousands of lines), for example `find <paths> -type f -printf '%p %s %T@\n' | sort > <RUN>/before.txt`. At the end write `<RUN>/after.txt` the same way and `cmp` the two files; they must be identical.

## Restrictions

Do not modify anything under the paths.
