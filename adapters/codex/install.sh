#!/usr/bin/env bash
set -euo pipefail

BASELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ADAPTER_DIR="$BASELINE_DIR/adapters/codex"
SKILLS_DIR="$HOME/.codex/skills"

echo "Installing Codex adapter..."

# Check for codex CLI
if ! command -v codex &>/dev/null; then
  echo "  Warning: 'codex' not found in PATH. Skipping Codex adapter."
  exit 0
fi

# Copy AGENTS.md to repo root
if [[ ! -f "$BASELINE_DIR/AGENTS.md" ]]; then
  cp "$ADAPTER_DIR/AGENTS.md" "$BASELINE_DIR/AGENTS.md"
  echo "  Copied AGENTS.md to repo root"
else
  echo "  AGENTS.md already exists at repo root — skipping"
fi

# Symlink core skill files to ~/.codex/skills/ if Codex supports it
if [[ -n "${CODEX_SKILLS_DIR:-}" ]] || [[ -d "$SKILLS_DIR" ]]; then
  TARGET_DIR="${CODEX_SKILLS_DIR:-$SKILLS_DIR}"
  mkdir -p "$TARGET_DIR"
  echo "  Symlinking core skills to $TARGET_DIR..."
  for skill_file in "$BASELINE_DIR"/core/skills/*.md; do
    skill_name=$(basename "$skill_file")
    if [[ ! -L "$TARGET_DIR/$skill_name" ]]; then
      ln -s "$skill_file" "$TARGET_DIR/$skill_name"
      echo "    Linked: $skill_name"
    else
      echo "    Already linked: $skill_name"
    fi
  done
else
  echo "  Note: ~/.codex/skills/ not found. Skill symlinking skipped."
  echo "  If Codex supports skill files, set CODEX_SKILLS_DIR and re-run."
fi

echo "  Codex adapter installed."
