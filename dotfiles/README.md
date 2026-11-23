# Shell and terminal setup

Read this to install or change the zsh and WezTerm config in `dotfiles/`. It is separate from the Claude Code install (`install.sh`).

## Install

Needs `git`. Linux and WSL are supported, macOS is untested; native Windows is not (run it from WSL).

```
cd ~/claude-config && ./install-dotfiles.sh
```

- `--dry-run` prints what would change. `--no-deps` skips cloning oh-my-zsh and its plugins.
- `~/.zshrc` is a symlink into this repo, so `git pull` updates it. Edit `dotfiles/zshrc`, not `~/.zshrc`.
- WezTerm config: a symlink to `~/.config/wezterm/wezterm.lua`. On WSL, WezTerm runs on Windows and reads `%USERPROFILE%\.wezterm.lua`, so the script copies the file there. Re-run the script after a pull to refresh it.
- Existing files are backed up to `~/.dotfiles-backups/` and the path is printed.
- Not installed for you: zsh, bat and the WezTerm app itself (the script prints the package command), and your login shell (it prints the `chsh` command).

## Keeping credentials out

- Put API keys, tokens and per-machine settings in `~/.zshrc.local`. The installer creates it (mode 600) and `dotfiles/zshrc` sources it. It is git-ignored.
- `dotfiles/zshenv` (linked to `~/.zshenv`) also sources it. zsh reads `.zshenv` for every shell, so tools started from a non-interactive login shell, such as Claude Code, see your credentials; `.zshrc` alone is only read by interactive shells. Keep `~/.zshrc.local` to `export` lines. Check a clean shell with `env -i HOME=$HOME PATH=$PATH zsh -lc 'printenv VAR >/dev/null && echo set'`.
- `./install-dotfiles.sh --scan` checks `dotfiles/` for key and token patterns, private keys and URLs with embedded passwords, and warns about hardcoded home paths. The installer refuses to run if it finds anything.
- `./install-dotfiles.sh --hook` installs a pre-commit hook that runs the scan. Run it once per clone.
- The scan is pattern-based, so skim a diff before pushing. If a secret was ever committed, rotate it; deleting the file does not remove it from history.

## Portability notes

- The `wez` function in the zshrc only exists on WSL.
- WezTerm uses the default WSL distro (`wsl --set-default <name>`) when on Windows, and the native shell elsewhere.
