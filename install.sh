#!/usr/bin/env bash
set -e

SKILL_DIR="$HOME/.claude/skills/wrap-up"
REPO="https://github.com/zhoushoujianwork/skill-wrap-up.git"

if [ -d "$SKILL_DIR/.git" ]; then
  echo "Updating wrap-up skill..."
  git -C "$SKILL_DIR" pull --ff-only
else
  echo "Installing wrap-up skill..."
  mkdir -p "$HOME/.claude/skills"
  git clone --depth=1 "$REPO" "$SKILL_DIR"
fi

echo "Done. Say '收尾' or 'wrap-up' in any Claude Code session to trigger."
