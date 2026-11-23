#!/bin/sh
# Install shell and terminal dotfiles (zsh, WezTerm) using symlinks.
#   ./install-dotfiles.sh            link zshrc, zshenv and wezterm config
#   ./install-dotfiles.sh --dry-run  print what would happen, change nothing
#   ./install-dotfiles.sh --scan     scan dotfiles/ for credentials, change nothing
#   ./install-dotfiles.sh --hook     install a git pre-commit hook that runs --scan
#   ./install-dotfiles.sh --no-deps  skip cloning oh-my-zsh and its plugins
# Needs: sh, grep, git. Existing files are backed up, never deleted.
# On WSL, wezterm.lua is copied to the Windows home (re-run to update it).

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P) || exit 1
SRC="$ROOT/dotfiles"
TS=$(date +%Y%m%d-%H%M%S)
BK="$HOME/.dotfiles-backups/claude-config-$TS"
DRY=0
SCAN=0
HOOK=0
DEPS=1

for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --scan) SCAN=1 ;;
    --hook) HOOK=1 ;;
    --no-deps) DEPS=0 ;;
    -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
    *) echo "unknown option: $a" >&2; exit 2 ;;
  esac
done

say() { printf '%s\n' "$*"; }
die() { printf '%s\n' "$*" >&2; exit 1; }

[ -d "$SRC" ] || die "missing $SRC"

# Credential scan. Exit 1 on any hit. Home paths only warn.
scan() {
  hits=$(grep -rnEIi \
    -e '(api[_-]?key|secret|token|passw(or)?d|credential|bearer)[A-Za-z0-9_]*[[:space:]]*[=:][[:space:]]*["'\'']?[A-Za-z0-9/+_.=-]{8,}' \
    -e 'gh[pousr]_[A-Za-z0-9]{20,}' \
    -e 'github_pat_[A-Za-z0-9_]{20,}' \
    -e 'sk-[A-Za-z0-9_-]{20,}' \
    -e 'hf_[A-Za-z0-9]{20,}' \
    -e 'AKIA[0-9A-Z]{16}' \
    -e 'AIza[0-9A-Za-z_-]{30,}' \
    -e 'xox[baprs]-[A-Za-z0-9-]{10,}' \
    -e '-----BEGIN [A-Z ]*PRIVATE KEY-----' \
    -e '[a-z]+://[^/[:space:]]+:[^/@[:space:]]+@' \
    -- "$SRC" 2>/dev/null)
  if [ -n "$hits" ]; then
    say "possible credentials found, fix before committing or installing:"
    say "$hits"
    return 1
  fi
  warn=$(grep -rnEI -e '/Users/[A-Za-z0-9._-]+' -e '/home/[A-Za-z0-9._-]+' -- "$SRC" 2>/dev/null)
  if [ -n "$warn" ]; then
    say "warning: hardcoded home paths (use \$HOME so it works on other machines):"
    say "$warn"
  fi
  say "scan: clean"
  return 0
}

if [ "$SCAN" = 1 ]; then scan; exit $?; fi

if [ "$HOOK" = 1 ]; then
  [ -d "$ROOT/.git" ] || die "$ROOT is not a git repo"
  hook="$ROOT/.git/hooks/pre-commit"
  if [ "$DRY" = 1 ]; then say "would: write $hook"; exit 0; fi
  [ -e "$hook" ] && cp "$hook" "$hook.bak"
  printf '#!/bin/sh\nexec "$(git rev-parse --show-toplevel)/install-dotfiles.sh" --scan\n' > "$hook"
  chmod +x "$hook"
  say "installed: $hook"
  exit 0
fi

# Refuse to install anything that fails the scan.
scan || exit 1

backup_made=0
link() { # $1 = source (absolute), $2 = destination
  src=$1
  dst=$2
  [ -e "$src" ] || { say "skip (not in repo): $src"; return 0; }
  if [ -L "$dst" ]; then
    [ "$(readlink "$dst")" = "$src" ] && return 0
    if [ "$DRY" = 1 ]; then say "would: repair link $dst -> $src"; return 0; fi
    rm -f "$dst" && ln -s "$src" "$dst" && say "repaired: $dst -> $src"
    return 0
  fi
  if [ -e "$dst" ]; then
    if [ "$DRY" = 1 ]; then say "would: back up $dst, then link $dst -> $src"; return 0; fi
    mkdir -p "$BK" || die "cannot create $BK"
    mv "$dst" "$BK/" || die "cannot back up $dst"
    backup_made=1
    ln -s "$src" "$dst" && say "linked (original backed up): $dst -> $src"
    return 0
  fi
  if [ "$DRY" = 1 ]; then say "would: link $dst -> $src"; return 0; fi
  mkdir -p "$(dirname -- "$dst")" && ln -s "$src" "$dst" && say "linked: $dst -> $src"
}

# Clone oh-my-zsh and the two plugins the zshrc uses (skipped if present).
clone() { # $1 = url, $2 = destination
  [ -d "$2" ] && return 0
  if [ "$DRY" = 1 ]; then say "would: clone $1 -> $2"; return 0; fi
  git clone --depth 1 "$1" "$2" >/dev/null 2>&1 && say "cloned: $2" || say "warning: could not clone $1"
}
if [ "$DEPS" = 1 ]; then
  if command -v git >/dev/null 2>&1; then
    OMZ="$HOME/.oh-my-zsh"
    clone https://github.com/ohmyzsh/ohmyzsh.git "$OMZ"
    clone https://github.com/zsh-users/zsh-autosuggestions "$OMZ/custom/plugins/zsh-autosuggestions"
    clone https://github.com/zsh-users/zsh-syntax-highlighting "$OMZ/custom/plugins/zsh-syntax-highlighting"
  else
    say "warning: git missing, skipped oh-my-zsh and plugins"
  fi
  case "$(uname -s)" in
    Darwin) PKGHINT="brew install zsh bat" ;;
    *) if command -v apt-get >/dev/null 2>&1; then PKGHINT="sudo apt install zsh bat"
       else PKGHINT="install zsh and bat with your package manager"; fi ;;
  esac
  command -v zsh >/dev/null 2>&1 || say "warning: zsh not found ($PKGHINT)"
  command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1 || say "warning: bat not found ($PKGHINT)"
  case "$SHELL" in
    */zsh) ;;
    *) command -v zsh >/dev/null 2>&1 && say "note: your login shell is not zsh, run: chsh -s \"\$(command -v zsh)\"" ;;
  esac
fi

is_wsl() { [ -n "$WSL_DISTRO_NAME" ] || grep -qi microsoft /proc/version 2>/dev/null; }

win_home() {
  p=$( (cd /mnt/c 2>/dev/null && cmd.exe /C 'echo %USERPROFILE%' 2>/dev/null) | tr -d '\r')
  [ -n "$p" ] && wslpath -u "$p" 2>/dev/null
}

copy_to() { # $1 = source, $2 = destination; copy, backing up a different existing file
  src=$1
  dst=$2
  if [ -f "$dst" ] && cmp -s "$src" "$dst"; then return 0; fi
  if [ "$DRY" = 1 ]; then say "would: copy $src -> $dst"; return 0; fi
  if [ -e "$dst" ]; then
    mkdir -p "$BK" || die "cannot create $BK"
    cp "$dst" "$BK/$(basename -- "$dst")" || die "cannot back up $dst"
    backup_made=1
  fi
  mkdir -p "$(dirname -- "$dst")" && cp "$src" "$dst" && say "copied: $dst"
}

link "$SRC/zshrc" "$HOME/.zshrc"
link "$SRC/zshenv" "$HOME/.zshenv"

if is_wsl; then
  WH=$(win_home)
  if [ -n "$WH" ] && [ -d "$WH" ]; then
    copy_to "$SRC/wezterm.lua" "$WH/.wezterm.lua"
  else
    say "warning: could not find the Windows home, copy dotfiles/wezterm.lua to %USERPROFILE%\\.wezterm.lua yourself"
  fi
else
  link "$SRC/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
fi

# Machine-local, untracked file for secrets and per-machine tweaks.
LOCAL="$HOME/.zshrc.local"
if [ ! -e "$LOCAL" ]; then
  if [ "$DRY" = 1 ]; then
    say "would: create $LOCAL"
  else
    printf '# Machine-local zsh config. Not tracked. Put API keys and tokens here.\n' > "$LOCAL"
    chmod 600 "$LOCAL"
    say "created: $LOCAL"
  fi
fi

if [ -f "$SRC/zshrc" ] && ! grep -q 'zshrc.local' "$SRC/zshrc"; then
  say "warning: dotfiles/zshrc does not source ~/.zshrc.local"
fi

[ "$backup_made" = 1 ] && say "backups: $BK"
if [ "$DRY" = 1 ]; then say "dry run: nothing changed"; exit 0; fi
say "done. Open a new terminal (or run: exec zsh)."
exit 0
