#!/bin/sh
# SessionStart hook: tell the user when 3 or more lessons are pending.
d=$(dirname -- "$0")/../docs
n=0
for f in "$d/_inbox.md" "$d/_inbox.processing"; do
  if [ -f "$f" ]; then
    c=$(grep -c '^- ' "$f" 2>/dev/null)
    n=$((n + ${c:-0}))
  fi
done
if [ "$n" -ge 3 ]; then
  printf '{"systemMessage":"%s lessons pending, run /curate"}\n' "$n"
fi
exit 0
