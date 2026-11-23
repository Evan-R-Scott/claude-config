# claude-config

My portable Claude Code setup: global instructions, on-demand docs, generic skills, and a loop that turns lessons from sessions into those docs.

## What is in it

| Part | What it is | Install | Options |
|---|---|---|---|
| Claude Code setup | Global instructions, docs, skills, shared settings | `./install.sh` | `./install.sh --help` |
| Skills | Plan, review, PR, Jira, Confluence and doc-writing skills | included above | `./install.sh --list` shows each skill, what it does and what it needs |
| Shell and terminal | zsh and WezTerm config (optional) | `./install-dotfiles.sh` | `./install-dotfiles.sh --help` |

## Quick start

Needs `git` and `python3`. Linux and WSL are tested, macOS is untested.

1. Clone: `git clone https://github.com/Evan-R-Scott/claude-config.git ~/claude-config`
2. Install the Claude Code setup: `cd ~/claude-config && ./install.sh` (only some skills: `./install.sh plan review`, their requirements come along)
3. Optional, shell and terminal: `./install-dotfiles.sh`

Both scripts take `--dry-run` to preview and change nothing.

## Keeping it up to date

Claude captures lessons by itself. Only these are manual:

| When | Do |
|---|---|
| A session starts with "N lessons pending, run /curate" | Run `/curate` in Claude Code, read the diff, confirm, answer yes to "push now?" |
| On another laptop, to get the latest | `git -C ~/claude-config pull --recurse-submodules` (re-run `./install.sh` if new skills were added) |
| You want the latest of a vendored skill (`owasp-security`) | `./install.sh --update`, then skim what it prints |

## Learn more

- [docs/guide/how-it-works.md](docs/guide/how-it-works.md): how lessons are captured, curated and used.
- [docs/README.md](docs/README.md): the full maintenance routine, undo steps, new-laptop setup and vendored skills.
- [dotfiles/README.md](dotfiles/README.md): what the shell setup does and how secrets are kept out.
