#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${LOG_FILE:-.planning/LOOP-LOG.md}"

if [ $# -ne 7 ]; then
  echo "Usage: $(basename "$0") <iteration> <hypothesis> <before> <after> <delta> <conditions> <decision>" >&2
  exit 1
fi

[ -f "$LOG_FILE" ] \
  || { echo "ERROR: $LOG_FILE not found. Run init-eval.sh first." >&2; exit 1; }

DATE=$(date +%Y-%m-%d)
printf "| %s | %s | %s | %s | %s | %s | %s | %s |\n" \
  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$DATE" >> "$LOG_FILE"
echo "Appended iteration $1 to $LOG_FILE"
