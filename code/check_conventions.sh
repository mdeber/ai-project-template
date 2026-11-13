#!/usr/bin/env bash
# ------------------------------------------------------------------
# check_conventions.sh
# purpose : check analysis folders against the layout in code/README.md: README sections, a log
#           entry, out/ subfolders only, a legend (and png) for every plot, script headers.
#           Reports problems; changes nothing.
# inputs  : analysis dirs given as arguments, or
#           --changed   the analyses under code/analysis/ with uncommitted changes, or
#           --hook      SubagentStop hook JSON on stdin: the analyses this subagent wrote to, plus --changed
# outputs : one line per violation on stdout; exit 0 clean, 1 violations, 2 usage.
#           In --hook mode, prints {"decision":"block","reason":…} so the subagent fixes them before
#           it finishes (allowed through on the second stop, stop_hook_active), and always exits 0.
# env     : bash, git, jq (/usr/bin/jq)
# run     : code/check_conventions.sh code/analysis/<name>    |   code/check_conventions.sh --changed
# runtime : seconds
# written : 261113   by: Claude Code / <name>
# ------------------------------------------------------------------
set -uo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
JQ=/usr/bin/jq
OUT_SUBDIRS='tables|plots|reports|objects|jobs'
SECTIONS=('question' 'inputs' 'method' '(planned )?outputs' 'reading the result' 'status' 'results' 'caveats')
NAMES=('Question' 'Inputs' 'Method' 'Planned outputs' 'Reading the result' 'Status' 'Results' 'Caveats')

changed_analyses() {
  git -C "$ROOT" status --porcelain --untracked-files=all -- code/analysis 2>/dev/null |
    sed -E 's/^.{3}//; s/.* -> //' | awk -F/ 'NF >= 3 { print $1"/"$2"/"$3 }' | sort -u
}

problems=()
add() { problems+=("$1: $2"); }

check_out_level() {   # $1 = analysis label, $2 = an out/ dir (or out/thru_<batch>), $3 = allow thru_ subdirs (1/0)
  local label=$1 dir=$2 allow_thru=$3 f d name loose=()
  while IFS= read -r f; do
    [ "$(basename "$f")" = .gitkeep ] || loose+=("$(basename "$f")")
  done < <(find "$dir" -mindepth 1 -maxdepth 1 -type f 2>/dev/null)
  [ ${#loose[@]} -gt 0 ] && add "$label" "${#loose[@]} loose file(s) in ${dir#$ROOT/}/, e.g. ${loose[*]:0:3} (move into ${OUT_SUBDIRS//|/, })"
  while IFS= read -r d; do
    name=$(basename "$d")
    if [[ $name =~ ^($OUT_SUBDIRS)$ ]]; then :
    elif [ "$allow_thru" = 1 ] && [[ $name =~ ^thru_ ]]; then check_out_level "$label" "$d" 0
    else add "$label" "unexpected folder ${d#$ROOT/}/ (out/ holds only ${OUT_SUBDIRS//|/, }; temporary files go in scratch/)"
    fi
  done < <(find "$dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

check_plots() {       # $1 = label, $2 = a plots/ dir
  local label=$1 dir=$2 f stem missing=() nopng=()
  while IFS= read -r f; do
    stem=${f%.*}
    [ -f "$stem.txt" ] || missing+=("${f#$dir/}")
    [[ $f == *.pdf ]] && [ ! -f "$stem.png" ] && nopng+=("${f#$dir/}")
  done < <(find "$dir" -maxdepth 2 -type f \( -name '*.pdf' -o -name '*.png' -o -name '*.svg' \) 2>/dev/null)
  [ ${#missing[@]} -gt 0 ] && add "$label" "${#missing[@]} plot(s) in ${dir#$ROOT/} without a .txt legend, e.g. ${missing[*]:0:3}"
  [ ${#nopng[@]} -gt 0 ] && add "$label" "${#nopng[@]} pdf(s) in ${dir#$ROOT/} without a .png, e.g. ${nopng[*]:0:3}"
}

check_dir() {
  local d=${1%/} label i f p
  [ -d "$d" ] || { add "$d" "not a directory"; return; }
  label=${d#$ROOT/}
  if [ ! -f "$d/README.md" ]; then add "$label" "no README.md"
  else
    for i in "${!SECTIONS[@]}"; do
      grep -qiE "^#+[[:space:]]*${SECTIONS[$i]}" "$d/README.md" || add "$label" "README.md has no '## ${NAMES[$i]}' section"
    done
  fi
  find "$d/log" -maxdepth 1 -type f -regextype posix-extended -regex '.*/[0-9]{6}_[0-9]{4}_[^/]+\.md' 2>/dev/null | grep -q . ||
    add "$label" "no log entry in log/ (YYMMDD_HHMM_<topic>.md, format in docs/log/README.md)"
  [ -d "$d/out" ] && check_out_level "$label" "$d/out" 1
  while IFS= read -r p; do check_plots "$label" "$p"; done < <(find "$d/out" -maxdepth 2 -type d -name plots 2>/dev/null)
  while IFS= read -r f; do
    head -15 "$f" | grep -qiE 'purpose[[:space:]]*:' || add "$label" "script $(basename "$f") has no header (purpose/inputs/outputs …; code/README.md)"
  done < <(find "$d" -maxdepth 1 -type f \( -name '*.py' -o -name '*.R' -o -name '*.r' -o -name '*.sh' -o -name '*.sbatch' -o -name '*.jl' \) 2>/dev/null)
}

mode=args; dirs=()
case "${1:-}" in
  --changed) mode=changed; while IFS= read -r a; do dirs+=("$ROOT/$a"); done < <(changed_analyses) ;;
  --hook)
    mode=hook; input=$(cat)
    [ "$(printf '%s' "$input" | $JQ -r '.stop_hook_active // false' 2>/dev/null)" = true ] && exit 0
    tp=$(printf '%s' "$input" | $JQ -r '.agent_transcript_path // empty' 2>/dev/null)
    if [ -n "$tp" ] && [ -f "$tp" ]; then
      while IFS= read -r f; do
        f=$(realpath -m "$f"); rel=${f#$ROOT/}
        [ "$rel" != "$f" ] && [[ $rel == code/analysis/*/* ]] && dirs+=("$ROOT/$(cut -d/ -f1-3 <<< "$rel")")
      done < <($JQ -r 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use" and (.name=="Write" or .name=="Edit")) | .input.file_path // empty' "$tp" 2>/dev/null)
    fi
    while IFS= read -r a; do dirs+=("$ROOT/$a"); done < <(changed_analyses) ;;
  ''|-h|--help) sed -n '2,17p' "${BASH_SOURCE[0]}"; exit 2 ;;
  *) dirs=("$@") ;;
esac

mapfile -t dirs < <(printf '%s\n' "${dirs[@]}" | grep -v '^$' | sort -u)
for d in "${dirs[@]}"; do [ -n "$d" ] && check_dir "$(realpath -m "$d")"; done

if [ "$mode" = hook ]; then
  [ ${#problems[@]} -eq 0 ] && exit 0
  reason=$(printf 'check_conventions: fix these in the analyses you worked on, then finish (layout and legend contract: code/README.md):\n'; printf -- '- %s\n' "${problems[@]:0:25}")
  $JQ -n --arg r "$reason" '{decision: "block", reason: $r}'
  exit 0
fi
[ ${#dirs[@]} -eq 0 ] && { echo "no analyses to check"; exit 0; }
[ ${#problems[@]} -eq 0 ] && { echo "ok: ${#dirs[@]} analysis folder(s) follow code/README.md"; exit 0; }
printf '%s\n' "${problems[@]}"; exit 1
