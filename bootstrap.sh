#!/usr/bin/env bash
set -euo pipefail

BASELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PERSONAL_MD="$BASELINE_DIR/core/context/personal.md"

echo "========================================"
echo " Agentic Baseline — Bootstrap"
echo "========================================"
echo ""

detected=()
skipped=()

run_adapter() {
  local name="$1"
  local script="$2"
  if [[ -x "$script" ]]; then
    bash "$script"
    detected+=("$name")
  else
    echo "  Warning: $script not executable — skipping"
    skipped+=("$name (install.sh not executable)")
  fi
}

# Claude Code
if command -v claude &>/dev/null; then
  echo "--- Claude Code detected ---"
  run_adapter "Claude Code" "$BASELINE_DIR/adapters/claude-code/install.sh"
  echo ""
else
  skipped+=("Claude Code (not installed)")
fi

# Codex
if command -v codex &>/dev/null; then
  echo "--- Codex detected ---"
  run_adapter "Codex" "$BASELINE_DIR/adapters/codex/install.sh"
  echo ""
else
  skipped+=("Codex (not installed)")
fi

# GitHub Copilot (detected via gh extension or environment)
if command -v gh &>/dev/null && gh extension list 2>/dev/null | grep -q "copilot"; then
  echo "--- GitHub Copilot detected ---"
  run_adapter "Copilot" "$BASELINE_DIR/adapters/copilot/install.sh"
  echo ""
else
  skipped+=("Copilot (not installed or gh extension not found)")
fi

# Make scripts executable
chmod +x "$BASELINE_DIR/update-loop/run-update.sh"
chmod +x "$BASELINE_DIR/intelligence/run-digest.sh"

echo "========================================"
echo " Summary"
echo "========================================"
echo ""

if [[ ${#detected[@]} -gt 0 ]]; then
  echo "Installed adapters:"
  for t in "${detected[@]}"; do
    echo "  ✓ $t"
  done
else
  echo "No adapters installed (no supported tools detected)."
fi

echo ""

if [[ ${#skipped[@]} -gt 0 ]]; then
  echo "Skipped:"
  for t in "${skipped[@]}"; do
    echo "  - $t"
  done
  echo ""
fi

# Check if personal.md has unfilled TODOs
TODO_COUNT=$(grep -c "\[TODO" "$PERSONAL_MD" 2>/dev/null || true)
if [[ "$TODO_COUNT" -gt 0 ]]; then
  echo "========================================"
  echo " Action Required"
  echo "========================================"
  echo ""
  echo "  core/context/personal.md has $TODO_COUNT unfilled TODO(s)."
  echo "  This is the highest-leverage file — fill it before first use."
  echo ""
  echo "  Run: \$EDITOR core/context/personal.md"
  echo ""
fi

echo "Done. Three loops to establish:"
echo "  After every task:           feedback-loop/post-task-template.md"
echo "  Weekly:                     ./intelligence/run-digest.sh"
echo "  Monthly (or on release):    ./update-loop/run-update.sh"
echo ""
