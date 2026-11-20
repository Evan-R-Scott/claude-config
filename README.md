# claude-config

My portable Claude Code setup: global instructions, on-demand docs, generic skills, and a loop that turns lessons from sessions into those docs.

## Quick start

Needs `git` and `python3`.

```
git clone <this repo> ~/claude-config
cd ~/claude-config && ./install.sh
```

Install only some skills (their requirements come along): `./install.sh plan review`. See what exists: `./install.sh --list`. Preview first: add `--dry-run`.

Read [docs/README.md](docs/README.md) to learn how the learning loop works and how to set up another laptop.
