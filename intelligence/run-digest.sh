#!/usr/bin/env bash
set -euo pipefail

BASELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIGESTS_DIR="$BASELINE_DIR/intelligence/digests"
TODAY=$(date +%Y-%m-%d)
OUTPUT_FILE="$DIGESTS_DIR/$TODAY.md"

echo "=== Intelligence Digest — $TODAY ==="
echo ""

# Check last digest
LAST_DIGEST=$(ls "$DIGESTS_DIR"/*.md 2>/dev/null | grep -v ".gitkeep" | sort | tail -1 || echo "")

if [[ -n "$LAST_DIGEST" ]]; then
  LAST_DATE=$(basename "$LAST_DIGEST" .md)
  echo "Last digest: $LAST_DATE"

  # Calculate days since last digest
  if command -v python3 &>/dev/null; then
    DAYS_SINCE=$(python3 -c "
from datetime import date
last = date.fromisoformat('$LAST_DATE')
today = date.fromisoformat('$TODAY')
print((today - last).days)
")
    echo "Days since last digest: $DAYS_SINCE"
    if [[ "$DAYS_SINCE" -lt 5 ]]; then
      echo ""
      echo "Warning: last digest was $DAYS_SINCE days ago. Run again when 7+ days have passed,"
      echo "or pass --force to override."
      if [[ "${1:-}" != "--force" ]]; then
        exit 0
      fi
    fi
    SCAN_WINDOW=$DAYS_SINCE
  else
    SCAN_WINDOW=7
  fi
else
  echo "Last digest: none (first run)"
  SCAN_WINDOW=30
fi

echo "Scan window: past $SCAN_WINDOW days"
echo "Output file: intelligence/digests/$TODAY.md"
echo ""

# Print the command to run
echo "=== Next Step ==="
echo ""
echo "Run the digest prompt with web search enabled."
echo "Edit the prompt first — fill in today's date and scan window:"
echo ""
echo "  Today: $TODAY"
echo "  Scan window: $SCAN_WINDOW days"
echo ""
echo "Prompt file: intelligence/digest-prompt.md"
echo "Sources:     intelligence/sources.md"
echo ""
echo "When the agent produces the digest, save it to:"
echo "  $OUTPUT_FILE"
echo ""
echo "Then commit:"
echo "  git add intelligence/digests/$TODAY.md"
echo "  git commit -m 'chore: weekly digest $TODAY'"
echo ""
echo "Optional delivery (via MCP):"
echo "  Slack:   pipe digest to a personal channel"
echo "  Gmail:   send to self"
echo "  ClickUp: create a task with digest as note"
echo ""
