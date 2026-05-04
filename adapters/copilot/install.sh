#!/usr/bin/env bash
set -euo pipefail

BASELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ADAPTER_DIR="$BASELINE_DIR/adapters/copilot"

echo "Installing Copilot adapter..."

# Copilot instructions go in .github/copilot-instructions.md per project
# We place a copy in the baseline root for reference — per-project setup is manual
GITHUB_DIR="$BASELINE_DIR/.github"
mkdir -p "$GITHUB_DIR"

if [[ ! -f "$GITHUB_DIR/copilot-instructions.md" ]]; then
  cp "$ADAPTER_DIR/copilot-instructions.md" "$GITHUB_DIR/copilot-instructions.md"
  echo "  Copied copilot-instructions.md to .github/"
else
  echo "  .github/copilot-instructions.md already exists — skipping"
fi

echo "  Copilot adapter installed."
echo ""
echo "  For each project repo: copy .github/copilot-instructions.md to the project's .github/ directory."
echo "  The file references /core relative paths — adjust paths if the baseline is not a sibling directory."
