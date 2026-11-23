#!/bin/sh
# Install this config into ~/.claude using symlinks.
#   ./install.sh                 full install (CLAUDE.md, docs, bin, every skill, shared settings)
#   ./install.sh plan review     only the named skills (and what they require); symlinks only
#   ./install.sh --list          list skills, what each does and what it requires
#   ./install.sh --dry-run ...   print what would happen, change nothing
#   ./install.sh --update        pull the latest of vendored skills (git submodules); nothing else changes
# Needs: sh. The full install also needs python3 (settings merge).

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P) || exit 1
CLAUDE="$HOME/.claude"
TS=$(date +%Y%m%d-%H%M%S)
BK="$CLAUDE/backups/claude-config-$TS"
DRY=0
LIST=0
UPDATE=0
NAMES=""

for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --list) LIST=1 ;;
    --update) UPDATE=1 ;;
    -h|--help) awk 'NR == 1 { next } /^#/ { print; next } { exit }' "$0"; exit 0 ;;
    -*) echo "unknown option: $a" >&2; exit 2 ;;
    *) NAMES="$NAMES $a" ;;
  esac
done

say() { printf '%s\n' "$*"; }
die() { printf '%s\n' "$*" >&2; exit 1; }

# Parse a skill's requires file. Prints one entry per line (cleaned, no blanks).
read_requires() {
  [ -f "$ROOT/skills/$1/requires" ] || return 0
  while IFS= read -r line || [ -n "$line" ]; do
    line=$(printf '%s' "$line" | tr -d '\r' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    [ -n "$line" ] && printf '%s\n' "$line"
  done < "$ROOT/skills/$1/requires"
}

all_skills() {
  for d in "$ROOT"/skills/*; do
    # a vendored skill is a symlink into a submodule: listed even before the submodule is fetched
    { [ -d "$d" ] || [ -L "$d" ]; } && basename "$d"
  done
}

# First sentence of a skill's description (from its SKILL.md frontmatter), so --list never goes stale.
skill_desc() {
  sed -n 's/^description: *"\{0,1\}//p' "$ROOT/skills/$1/SKILL.md" | head -n 1 | sed 's/"$//' |
    awk '{ i = index($0, ". "); if (i > 0) $0 = substr($0, 1, i);
          if (length($0) > 100) { $0 = substr($0, 1, 100); sub(/ [^ ]*$/, "", $0); $0 = $0 "..." }
          print }'
}

if [ "$LIST" = 1 ]; then
  for s in $(all_skills); do
    req=$(read_requires "$s" | tr '\n' ' ' | sed 's/[[:space:]]*$//')
    case " $req " in
      *" @full-install "*) say "$s  (full install only)" ;;
      "  ") say "$s" ;;
      *) say "$s  (requires: $req)" ;;
    esac
    if [ -f "$ROOT/skills/$s/SKILL.md" ]; then say "    $(skill_desc "$s")"; else say "    (vendored: fetched by ./install.sh)"; fi
  done
  exit 0
fi

if [ "$UPDATE" = 1 ]; then
  { [ -f "$ROOT/.gitmodules" ] && [ -e "$ROOT/.git" ]; } || die "no vendored skills to update (needs a git clone with .gitmodules)"
  if [ "$DRY" = 1 ]; then say "would: git submodule update --init --remote"; exit 0; fi
  git -C "$ROOT" submodule update --init --remote || die "update failed (network, or local changes inside vendor/)"
  git -C "$ROOT" submodule summary
  say "vendored skills are up to date with their upstream. Skim what changed above: it is third-party text that Claude will follow."
  say "If you maintain this repo, commit the new pointer: git -C $ROOT add vendor && git -C $ROOT commit"
  exit 0
fi

# Vendored skills live in git submodules (see .gitmodules). Fetch any that are missing,
# so a plain clone (without --recurse-submodules) still gets them.
if [ -f "$ROOT/.gitmodules" ] && [ -e "$ROOT/.git" ]; then
  if git -C "$ROOT" submodule status | grep -q '^-'; then
    if [ "$DRY" = 1 ]; then
      say "would: git submodule update --init"
    else
      git -C "$ROOT" submodule update --init || die "could not fetch vendored skills (network?), see .gitmodules"
    fi
  fi
fi

# Resolve requested skills plus requirements. Sets RESOLVED and FULLONLY.
resolve() {
  RESOLVED=""
  FULLONLY=0
  queue="$*"
  while [ -n "$queue" ]; do
    # shellcheck disable=SC2086
    set -- $queue
    n=$1
    shift
    queue="$*"
    case "$n" in
      */*|.*|"") echo "unknown skill: $n" >&2; return 1 ;;
    esac
    case " $RESOLVED " in *" $n "*) continue ;; esac
    [ -d "$ROOT/skills/$n" ] || { echo "unknown skill: $n" >&2; return 1; }
    RESOLVED="$RESOLVED $n"
    for r in $(read_requires "$n"); do
      if [ "$r" = "@full-install" ]; then FULLONLY=1; else queue="$queue $r"; fi
    done
  done
  return 0
}

# Full install = everything. A named install = those skills only.
FULL=0
if [ -z "$NAMES" ]; then
  FULL=1
  # shellcheck disable=SC2046
  resolve $(all_skills) || exit 1
else
  # shellcheck disable=SC2086
  resolve $NAMES || exit 1
  if [ "$FULLONLY" = 1 ]; then
    die "a requested skill needs the full install, run ./install.sh"
  fi
fi

# Preflight for the full install: python3 and a valid settings.json, before any change.
if [ "$FULL" = 1 ]; then
  command -v python3 >/dev/null 2>&1 || die "missing python3 (needed for the settings merge)"
fi

merge_settings() { # $1 = check | apply | dry
  python3 -I - "$CLAUDE/settings.json" "$ROOT/settings.shared.json" "$BK" "$1" <<'PY'
import json, os, shutil, stat, sys, tempfile

settings, shared, bkdir, mode = sys.argv[1:5]
with open(shared, encoding="utf-8") as f:
    sh = json.load(f)

real = os.path.realpath(settings)
exists = os.path.exists(real)
cur = {}
if exists:
    with open(real, encoding="utf-8") as f:
        raw = f.read()
    if raw.strip():
        try:
            cur = json.loads(raw)
        except ValueError as e:
            sys.exit("settings.json is not valid JSON: %s" % e)
        if not isinstance(cur, dict):
            sys.exit("settings.json is not a JSON object")

new = json.loads(json.dumps(cur))

for key, val in sh.items():
    if key == "permissions" and isinstance(val, dict):
        perms = new.setdefault("permissions", {})
        for lk, items in val.items():
            lst = perms.setdefault(lk, [])
            for item in items:
                if item not in lst:
                    lst.append(item)
    elif key == "hooks" and isinstance(val, dict):
        hooks = new.setdefault("hooks", {})
        for event, entries in val.items():
            local = hooks.setdefault(event, [])
            for sh_entry in entries:
                matcher = sh_entry.get("matcher")
                same = [e for e in local if e.get("matcher") == matcher]
                for h in sh_entry.get("hooks", []):
                    placed = False
                    for e in same:
                        for i, lh in enumerate(e.get("hooks", [])):
                            if lh.get("type") == h.get("type") and lh.get("command") == h.get("command"):
                                e["hooks"][i] = h
                                placed = True
                                break
                        if placed:
                            break
                    if not placed:
                        if same:
                            same[0].setdefault("hooks", []).append(h)
                        else:
                            entry = {k: v for k, v in sh_entry.items() if k != "hooks"}
                            entry["hooks"] = [h]
                            local.append(entry)
                            same = [entry]
    elif key not in new:
        new[key] = val

changed = (not exists) or new != cur
if mode == "check":
    sys.exit(0)
if not changed:
    print("settings: unchanged")
    sys.exit(0)
if mode == "dry":
    print("would: %s settings.json" % ("create" if not exists else "merge into"))
    sys.exit(0)

if exists:
    os.makedirs(bkdir, exist_ok=True)
    shutil.copy2(real, os.path.join(bkdir, "settings.json"))
    perm = stat.S_IMODE(os.stat(real).st_mode)
else:
    os.makedirs(os.path.dirname(real), exist_ok=True)
    perm = 0o644
fd, tmp = tempfile.mkstemp(dir=os.path.dirname(real), prefix=".settings.")
with os.fdopen(fd, "w", encoding="utf-8") as f:
    json.dump(new, f, indent=2, ensure_ascii=False)
    f.write("\n")
os.chmod(tmp, perm)
os.replace(tmp, real)
print("settings: %s" % ("created" if not exists else "merged"))
PY
}

if [ "$FULL" = 1 ]; then
  merge_settings check || exit 1
fi

backup_made=0
link() { # $1 = source (absolute), $2 = destination
  src=$1
  dst=$2
  if [ -L "$dst" ]; then
    if [ "$(readlink "$dst")" = "$src" ]; then
      return 0
    fi
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

[ "$DRY" = 1 ] || mkdir -p "$CLAUDE/skills"

if [ "$FULL" = 1 ]; then
  link "$ROOT/CLAUDE.md" "$CLAUDE/CLAUDE.md"
  link "$ROOT/docs" "$CLAUDE/docs"
  link "$ROOT/bin" "$CLAUDE/bin"
fi

extra=""
for s in $RESOLVED; do
  case " $NAMES " in *" $s "*) ;; *) extra="$extra $s" ;; esac
done
if [ "$FULL" = 0 ] && [ -n "$extra" ]; then say "also installing:$extra"; fi

for s in $RESOLVED; do
  link "$ROOT/skills/$s" "$CLAUDE/skills/$s"
done

if [ "$FULL" = 1 ]; then
  inbox="$ROOT/docs/_inbox.md"
  if [ ! -f "$inbox" ]; then
    if [ "$DRY" = 1 ]; then
      say "would: create $inbox"
    else
      cat > "$inbox" <<'EOF'
# Inbox: candidate lessons (git-ignored, local to this machine)
# One lesson per line, appended by bin/capture-lesson.sh and merged by /curate.
# An entry is a line that starts with a dash and a space, then: rule | why: reason
EOF
      say "created: $inbox"
    fi
  fi
  [ "$DRY" = 1 ] || chmod +x "$ROOT"/bin/*.sh
  if [ "$DRY" = 1 ]; then merge_settings dry || exit 1; else merge_settings apply || exit 1; fi
fi

[ "$backup_made" = 1 ] || [ -f "$BK/settings.json" ] && say "backups: $BK"
if [ "$DRY" = 1 ]; then say "dry run: nothing changed"; exit 0; fi
if [ "$FULL" = 1 ]; then
  say "done. Log in to Claude Code if this is a new machine, then start a session."
else
  say "done."
fi
exit 0
