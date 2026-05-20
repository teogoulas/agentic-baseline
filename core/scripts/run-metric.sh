#!/usr/bin/env bash
set -euo pipefail

EVAL_FILE="${EVAL_FILE:-.planning/EVAL.md}"

[ -f "$EVAL_FILE" ] \
  || { echo "ERROR: $EVAL_FILE not found. Run init-eval.sh first." >&2; exit 1; }

CMD=$(grep -E '^\*\*How to run:\*\*' "$EVAL_FILE" 2>/dev/null \
  | sed 's/^\*\*How to run:\*\* //' \
  | sed 's/^`//;s/`$//' || true)

[ -n "$CMD" ] \
  || { echo "ERROR: 'How to run' field not set in $EVAL_FILE" >&2; exit 1; }

RESULT=$(eval "$CMD" 2>&1) || {
  echo "ERROR: metric command failed: $RESULT" >&2
  exit 1
}

echo "$RESULT" | grep -qE '^-?[0-9]+(\.[0-9]+)?$' \
  || { echo "ERROR: command output is not numeric: '$RESULT'" >&2; exit 1; }

echo "$RESULT"
