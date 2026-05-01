#!/usr/bin/env bash
# Olympus Fleet Bootstrap — quick setup
# Usage: bash setup.sh [target-dir]
# Default target = current dir

set -euo pipefail

TARGET="${1:-.}"

echo "Olympus Fleet Bootstrap"
echo "Target: $TARGET"
echo ""

# 1. Verify prereqs
echo "Checking prereqs..."
command -v claude >/dev/null 2>&1 || { echo "ERROR: claude (Claude Code) not found"; exit 1; }
command -v gh >/dev/null 2>&1 || { echo "ERROR: gh (GitHub CLI) not found"; exit 1; }
command -v git >/dev/null 2>&1 || { echo "ERROR: git not found"; exit 1; }
command -v python >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1 || { echo "ERROR: python 3.12+ not found"; exit 1; }
command -v node >/dev/null 2>&1 || { echo "ERROR: node not found"; exit 1; }
echo "OK"

# 2. Create .kiro skeleton
echo ""
echo "Creating .kiro skeleton..."
mkdir -p "$TARGET/.kiro"/{steering,steering/protocol,specs,handoffs,best-practice,skills,audits/auto-validate,templates}
echo "OK"

# 3. Copy BOOTSTRAP.md to .kiro/templates/
echo ""
echo "Installing BOOTSTRAP.md..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR/BOOTSTRAP.md" "$TARGET/.kiro/templates/olympus-fleet-bootstrap.md"
echo "OK"

# 4. Install claude-memory-compiler (long-term memory)
echo ""
echo "Installing claude-memory-compiler (long-term memory)..."
SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$SKILLS_DIR"
if [ ! -d "$SKILLS_DIR/claude-memory-compiler" ]; then
  git clone https://github.com/coleam00/claude-memory-compiler "$SKILLS_DIR/claude-memory-compiler"
  cd "$SKILLS_DIR/claude-memory-compiler"
  pip install -e . || python3 -m pip install -e .
  cd - >/dev/null
fi
echo "OK"

# 5. Verify playwright MCP config
echo ""
echo "Checking playwright MCP..."
CLAUDE_CONFIG="$HOME/.claude.json"
if [ -f "$CLAUDE_CONFIG" ]; then
  if grep -q "playwright" "$CLAUDE_CONFIG" 2>/dev/null; then
    echo "OK (playwright MCP found in ~/.claude.json)"
  else
    echo "WARN: playwright MCP not configured in ~/.claude.json"
    echo "Add this to mcpServers:"
    echo '  "playwright": { "command": "npx", "args": ["@playwright/mcp@latest"] }'
  fi
else
  echo "WARN: ~/.claude.json not found, playwright MCP not configured"
fi

# 6. Done
echo ""
echo "Bootstrap skeleton ready."
echo ""
echo "Next steps:"
echo "1. Start Claude Code in $TARGET"
echo "2. Give Claude this prompt:"
echo ""
echo "   You are the new project zeus session. Read .kiro/templates/olympus-fleet-bootstrap.md fully."
echo "   Follow sections 1-14 in order. Report after each step. Ask user when stuck."
echo "   Do not autonomously decide business direction."
echo ""
echo "Done."
