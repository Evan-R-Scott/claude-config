# claude-config

My portable Claude Code setup: global instructions, on-demand docs, generic skills, and a loop that turns lessons from sessions into those docs.

## Quick start

Needs `git` and `python3`.

```
git clone <this repo> ~/claude-config
cd ~/claude-config && ./install.sh
```

Install only some skills (their requirements come along): `./install.sh plan review`. See what exists: `./install.sh --list`. Preview first: add `--dry-run`.

## Keeping it up to date

Claude captures lessons by itself. Only two things are manual:

1. **When a session starts with "N lessons pending, run /curate"**, run this in Claude Code (any folder): `/curate`
   Read the diff it shows, confirm, and answer yes to "push now?".
2. **On another laptop, to get the latest**: `git -C ~/claude-config pull` (re-run `./install.sh` only if new skills were added).

Review what is learned in `~/claude-config/docs/` (five short files, plus `CLAUDE.md`). Pending lessons wait in `~/claude-config/docs/_inbox.md`.

Read [docs/guide/how-it-works.md](docs/guide/how-it-works.md) to understand how lessons are captured, curated and used.
Read [docs/README.md](docs/README.md) for the full maintenance routine, undo steps and new-laptop setup.
