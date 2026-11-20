# How this works

Read this to understand the learning loop, set up a new laptop, or run `/curate`.

- `CLAUDE.md` holds the always-on rules and a "Read on demand" list that points at the topic docs here.
- Topic docs (`workflow`, `debugging`, `testing`, `communication`, `tooling`) hold general lessons, each capped at 80 lines.
- While you work, Claude records general lessons with `bin/capture-lesson.sh` into `docs/_inbox.md` (local to each machine, not in git). A start-of-session reminder appears when 3 or more are pending.
- Run `/curate` to merge them into the topic docs. It shows a diff and writes only after you confirm. The promotion gate is defined in `skills/curate/SKILL.md`.

## New laptop

1. Install `git` and `python3`, then clone this repo anywhere and run `./install.sh`.
2. Log in to Claude Code. Credentials, history and plugins stay local to each machine and are never in this repo.
3. Employer-specific skills are kept out of this repo on purpose.

## Notes

- Linux and WSL are tested. macOS is untested. Native Windows is unsupported (use WSL).
- Claude Code ignores a symlinked `~/.claude/CLAUDE.md` in Cowork desktop sessions; the CLI is unaffected.
- `./install.sh` backs up anything it replaces under `~/.claude/backups/` and prints the path.
