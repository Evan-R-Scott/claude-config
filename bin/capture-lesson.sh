#!/bin/sh
# Append one candidate lesson to the inbox.
# Usage: capture-lesson.sh -- '<rule> | why: <reason>'
[ "$1" = "--" ] && shift
if [ $# -ne 1 ]; then
  echo "usage: capture-lesson.sh -- '<rule> | why: <reason>'" >&2
  exit 2
fi
line=$(printf '%s' "$1" | tr '\r\n' '  ' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
if [ -z "$line" ]; then
  echo "capture-lesson: empty lesson, nothing written" >&2
  exit 1
fi
if [ "${#line}" -gt 500 ]; then
  echo "capture-lesson: lesson over 500 characters, nothing written" >&2
  exit 1
fi
inbox=$(dirname -- "$0")/../docs/_inbox.md
printf -- '- %s\n' "$line" >> "$inbox"
