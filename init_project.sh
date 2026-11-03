#!/usr/bin/env bash
# Instantiate a project from this template.
# usage: init_project.sh <absolute project dir> <lab: pena|krienen> "<one-line description>"
set -euo pipefail
DEST="$1"; LAB="$2"; DESC="${3:-}"
NAME="$(basename "$DEST")"
TEMPLATE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -e "$DEST" ] && { echo "refusing: $DEST exists"; exit 1; }
mkdir -p "$DEST"
cp -r "$TEMPLATE"/. "$DEST"/
rm -rf "$DEST/init_project.sh" "$DEST/.git"
NOW_D=$(date +%y%m%d); NOW_T=$(date +%H%M)
grep -rl '__' "$DEST" --include='*.md' --include='*.yaml' | xargs sed -i \
  -e "s|__PROJECT__|$NAME|g" -e "s|__LAB__|$LAB|g" -e "s|__REPO_ROOT__|$DEST|g" \
  -e "s|__ONE_LINE_DESCRIPTION__|$DESC|g" -e "s|__YYMMDD__|$NOW_D|g" -e "s|__HHMM__|$NOW_T|g"
cd "$DEST" && git init -q && git add -A && git commit -qm "setup: initialize from pni-project-template"
echo "initialized $DEST"
echo "next: open a Claude Code session there and run the project kickoff"
