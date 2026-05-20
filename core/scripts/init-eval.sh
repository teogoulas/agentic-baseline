#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="${TEMPLATES_DIR:-$SCRIPT_DIR/../templates}"
PLANNING_DIR="${PLANNING_DIR:-.planning}"
FORCE="${FORCE:-0}"

[ -f "$TEMPLATES_DIR/EVAL.md" ] \
  || { echo "ERROR: $TEMPLATES_DIR/EVAL.md not found" >&2; exit 1; }
[ -f "$TEMPLATES_DIR/LOOP-LOG.md" ] \
  || { echo "ERROR: $TEMPLATES_DIR/LOOP-LOG.md not found" >&2; exit 1; }

mkdir -p "$PLANNING_DIR"

for f in EVAL.md LOOP-LOG.md; do
  if [ -f "$PLANNING_DIR/$f" ] && [ "$FORCE" != "1" ]; then
    echo "SKIP: $PLANNING_DIR/$f already exists (set FORCE=1 to overwrite)"
  else
    cp "$TEMPLATES_DIR/$f" "$PLANNING_DIR/$f"
    echo "Created $PLANNING_DIR/$f"
  fi
done
