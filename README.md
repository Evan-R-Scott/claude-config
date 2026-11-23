# claude-config

My portable Claude Code setup: global instructions, on-demand docs, generic skills, and a loop that turns lessons from sessions into those docs.

## Quick start

Needs `git` and `python3`.

```
git clone --recurse-submodules https://github.com/Evan-R-Scott/claude-config.git ~/claude-config
cd ~/claude-config && ./install.sh
```

Install only some skills (their requirements come along): `./install.sh plan review`. See what exists: `./install.sh --list`. Preview first: add `--dry-run`.

## Skills

`./install.sh --list` shows every skill, what it does and what it needs. `./install.sh --help` shows all options.

## Shell and terminal setup

Optional: my zsh and WezTerm config, one script, works on Linux and WSL (macOS untested).

```
cd ~/claude-config && ./install-dotfiles.sh
```

Read [dotfiles/README.md](dotfiles/README.md) for what it does, how secrets are kept out and how to preview first.

## Keeping it up to date

Claude captures lessons by itself. Only these are manual:

1. **When a session starts with "N lessons pending, run /curate"**, run this in Claude Code (any folder): `/curate`
   Read the diff it shows, confirm, and answer yes to "push now?".
2. **On another laptop, to get the latest**: `git -C ~/claude-config pull` (re-run `./install.sh` only if new skills were added).

3. **Vendored skills** (`owasp-security`, from [agamm/claude-code-owasp](https://github.com/agamm/claude-code-owasp)) are git submodules pinned to a reviewed commit. `./install.sh` fetches them if the clone skipped `--recurse-submodules`. Anyone who cloned this repo can pull the latest of that skill any time with `./install.sh --update` (it moves only the vendored skills to their upstream tip, and prints what changed: skim it, it is third-party text Claude will follow). If you maintain this repo, commit the new pointer afterwards (`git add vendor && git commit`) so everyone else gets it with a normal `git pull` plus `git submodule update`.

Review what is learned in `~/claude-config/docs/` (five short files, plus `CLAUDE.md`). Pending lessons wait in `~/claude-config/docs/_inbox.md`.

Read [docs/guide/how-it-works.md](docs/guide/how-it-works.md) to understand how lessons are captured, curated and used.
Read [docs/README.md](docs/README.md) for the full maintenance routine, undo steps and new-laptop setup.
