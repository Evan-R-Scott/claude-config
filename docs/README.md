# Maintenance and setup

Read this to maintain the learning loop, set up a new laptop, or undo a curation. Read [guide/how-it-works.md](guide/how-it-works.md) to understand how capture and curation work.

- `CLAUDE.md` holds the always-on rules and a "Read on demand" list that points at the topic docs here.
- Topic docs (`workflow`, `debugging`, `testing`, `communication`, `tooling`) hold general lessons, each capped at 80 lines.
- While you work, Claude records general lessons with `bin/capture-lesson.sh` into `docs/_inbox.md` (local to each machine, not in git). A start-of-session reminder appears when 3 or more are pending.
- Run `/curate` to merge them into the topic docs. It shows a diff and writes lessons only after you confirm (before that it only pulls and commits a checkpoint of your own uncommitted edits to the docs). The promotion gate is defined in `skills/curate/SKILL.md`.

## Maintenance routine

| When | Do | Where |
|---|---|---|
| Session start shows "N lessons pending" | Run `/curate` in Claude Code | any folder |
| `/curate` shows its diff | Check each promoted rule is general (no project, host or path names) and rejected ones deserve rejecting, then confirm | the diff in the session |
| `/curate` asks "push now?" | Answer yes so other laptops get it | pushes to GitHub |
| Now and then (monthly) | Skim the topic docs, delete or fix rules that no longer hold | `~/claude-config/docs/*.md`, `~/claude-config/CLAUDE.md` |
| Another laptop | `git -C ~/claude-config pull --recurse-submodules` | that laptop |
| Curate result looks wrong | Finished run: `git -C ~/claude-config revert <commit>`. Unfinished run: `git -C ~/claude-config checkout -- CLAUDE.md docs` | `~/claude-config` |

Pending lessons: `cat ~/claude-config/docs/_inbox.md` (local to each laptop, not in git). Lessons are captured automatically when you correct Claude or state a preference. Curation is deliberately manual so nothing is written to your global rules without your review.

## New laptop

1. Install `git` and `python3`, then clone this repo anywhere and run `./install.sh`.
2. Log in to Claude Code. Credentials, history and plugins stay local to each machine and are never in this repo.
3. Employer-specific skills are kept out of this repo on purpose.

## Vendored skills

`owasp-security` comes from [agamm/claude-code-owasp](https://github.com/agamm/claude-code-owasp) as a git submodule (`vendor/`), pinned to a reviewed commit. Nothing changes in anyone's Claude sessions until they update.

- A plain `git clone` is enough: `./install.sh` fetches the submodules itself.
- Anyone can pull the latest with `./install.sh --update`. It moves only the vendored skills to their upstream tip and prints what changed. Skim it: it is third-party text that Claude will follow.
- If you maintain this repo, commit the new pointer afterwards (`git add vendor && git commit`), so everyone else gets it with `git pull --recurse-submodules` (a plain `git pull` leaves the submodule at its old commit, and `./install.sh` does not move it).

## Notes

- Linux and WSL are tested. macOS is untested. Native Windows is unsupported (use WSL).
- `./install-dotfiles.sh` is a separate installer for the shell and terminal config. See [../dotfiles/README.md](../dotfiles/README.md).
- Claude Code ignores a symlinked `~/.claude/CLAUDE.md` in Cowork desktop sessions; the CLI is unaffected.
- `./install.sh` backs up anything it replaces under `~/.claude/backups/` and prints the path.
