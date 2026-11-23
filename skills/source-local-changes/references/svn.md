# svn working copies

Read in full when the working copy is svn (`svn info <path> --show-item wc-root` succeeds and git does not, or svn's root is the closer one). It replaces the git-specific parts of `SKILL.md`; the run directory, trust rules for history, the engine and the report work the same way. Read-only.

- **Root:** the output of `svn info <path> --show-item wc-root`.
- **Scopes:** (none) is all modified, added and deleted files plus unversioned ones against BASE. `--staged` and `--unstaged` do not exist: report and stop. `--base <rev>`: `svn diff -r <rev> <root>`. `--commit <id>`: `svn diff -c <rev> <root>`. `--range <a>..<b>`: `svn diff -r <a>:<b> <root>`. A subdirectory or `--only` path is passed to `svn status` and `svn diff`.
- **Trust:** changes in the working copy are trusted; `--commit` and `--range` are untrusted unless the user passed `--trust`.
- **Collect:** `svn info <root>`, `svn status <root>`, `svn diff <root>`. Unversioned (`?`) files have no diff: treat each as fully added, with the same skip rules as git (binaries, build output, large or generated files). Conflicted (`C`) or missing (`!`) entries are findings in themselves. Honor `svn:ignore` (already reflected in `svn status`).
- **Base and execution copy:** the base is `svn export -r BASE <root> <RUN>/base-tree`. For `--commit` or `--range`: `svn export -r <rev-or-b> <root> <RUN>/tree`.
- **Read:** the new version is the file in the working copy; the base is `svn cat -r BASE <path>`. History: `svn log <root> -l 10` (it may need authentication; if it fails, say so and go on).
- **Untouched check:** record `svn status <root>` into `<RUN>/before.txt` and `<RUN>/after.txt` and `cmp` them, as in `SKILL.md`.
- **Restrictions:** never add, rm, revert, update, commit, cleanup, switch or propset.
