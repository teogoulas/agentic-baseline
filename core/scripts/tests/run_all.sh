#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for f in "$SCRIPT_DIR"/test_*.sh; do
  echo "=== $(basename "$f") ==="
  bash "$f"
  echo ""
done

for f in "$SCRIPT_DIR"/test_*.py; do
  [ -f "$f" ] || continue
  echo "=== $(basename "$f") ==="
  python3 "$f"
  echo ""
done

echo "All test suites complete."
