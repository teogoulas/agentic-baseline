#!/usr/bin/env bash
set -euo pipefail

BASELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ADAPTER_DIR="$BASELINE_DIR/adapters/claude-code"

echo "Installing Claude Code adapter..."

# Check for claude CLI
if ! command -v claude &>/dev/null; then
  echo "  Warning: 'claude' not found in PATH. Skipping Claude Code adapter."
  echo "  Install Claude Code first: https://claude.ai/code"
  exit 0
fi

# Copy CLAUDE.md to the current project directory if one doesn't exist
# (bootstrap.sh runs from the baseline root — each project gets its own CLAUDE.md via clone)
if [[ ! -f "$BASELINE_DIR/CLAUDE.md" ]]; then
  cp "$ADAPTER_DIR/CLAUDE.md" "$BASELINE_DIR/CLAUDE.md"
  echo "  Copied CLAUDE.md to repo root"
else
  echo "  CLAUDE.md already exists at repo root — skipping (review manually if needed)"
fi

echo "  Claude Code adapter installed."
echo ""
echo "  To use in a project: copy CLAUDE.md to the project root, or symlink it."
echo "  The file references /core relative to its location — keep the path relationship intact."
