# Maintenance and setup

Read this to maintain the learning loop, set up a new laptop, or undo a curation. Read [guide/how-it-works.md](guide/how-it-works.md) to understand how capture and curation work.

- `CLAUDE.md` holds the always-on rules and a "Read on demand" list that points at the topic docs here.
- Topic docs (`workflow`, `debugging`, `testing`, `communication`, `tooling`) hold general lessons, each capped at 80 lines.
- While you work, Claude records general lessons with `bin/capture-lesson.sh` into `docs/_inbox.md` (local to each machine, not in git). A start-of-session reminder appears when 3 or more are pending.
- Run `/curate` to merge them into the topic docs. It shows a diff and writes only after you confirm. The promotion gate is defined in `skills/curate/SKILL.md`.

## Maintenance routine

| When | Do | Where |
|---|---|---|
| Session start shows "N lessons pending" | Run `/curate` in Claude Code | any folder |
| `/curate` shows its diff | Check each promoted rule is general (no project, host or path names) and rejected ones deserve rejecting, then confirm | the diff in the session |
| `/curate` asks "push now?" | Answer yes so other laptops get it | pushes to GitHub |
| Now and then (monthly) | Skim the topic docs, delete or fix rules that no longer hold | `~/claude-config/docs/*.md`, `~/claude-config/CLAUDE.md` |
| Another laptop | `git -C ~/claude-config pull` | that laptop |
| Curate result looks wrong | Finished run: `git -C ~/claude-config revert <commit>`. Unfinished run: `git -C ~/claude-config checkout -- CLAUDE.md docs` | `~/claude-config` |

Pending lessons: `cat ~/claude-config/docs/_inbox.md` (local to each laptop, not in git). Lessons are captured automatically when you correct Claude or state a preference. Curation is deliberately manual so nothing is written to your global rules without your review.

## New laptop

1. Install `git` and `python3`, then clone this repo anywhere and run `./install.sh`.
2. Log in to Claude Code. Credentials, history and plugins stay local to each machine and are never in this repo.
3. Employer-specific skills are kept out of this repo on purpose.

## Notes

- Linux and WSL are tested. macOS is untested. Native Windows is unsupported (use WSL).
- `./install-dotfiles.sh` is a separate installer for the shell and terminal config. See [dotfiles.md](dotfiles.md).
- Claude Code ignores a symlinked `~/.claude/CLAUDE.md` in Cowork desktop sessions; the CLI is unaffected.
- `./install.sh` backs up anything it replaces under `~/.claude/backups/` and prints the path.
