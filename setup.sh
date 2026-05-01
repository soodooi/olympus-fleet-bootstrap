#!/usr/bin/env bash
# Olympus Fleet Bootstrap — quick setup v1.1
# Usage: bash setup.sh [target-dir]
# Default target = current dir

set -euo pipefail

TARGET="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Olympus Fleet Bootstrap v1.1"
echo "Target: $TARGET"
echo ""

# ─── Step 1: Verify prereqs ──────────────────────────────────────────────
echo "[1/7] Checking prereqs..."
command -v claude >/dev/null 2>&1 || { echo "ERROR: claude (Claude Code) not found"; exit 1; }
command -v gh >/dev/null 2>&1 || { echo "ERROR: gh (GitHub CLI) not found"; exit 1; }
command -v git >/dev/null 2>&1 || { echo "ERROR: git not found"; exit 1; }
command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1 || { echo "ERROR: python 3.12+ not found"; exit 1; }
command -v node >/dev/null 2>&1 || { echo "ERROR: node not found"; exit 1; }
echo "OK"

# ─── Step 2: Create .kiro skeleton ────────────────────────────────────────
echo ""
echo "[2/7] Creating .kiro skeleton..."
mkdir -p "$TARGET/.kiro"/{steering,steering/protocol,specs,handoffs,best-practice,skills,audits/auto-validate,templates}
mkdir -p "$TARGET/scripts"
echo "OK"

# ─── Step 3: Copy BOOTSTRAP.md + 5 protocol templates + fleet-status.sh ──
echo ""
echo "[3/7] Installing templates..."
cp "$SCRIPT_DIR/BOOTSTRAP.md" "$TARGET/.kiro/templates/olympus-fleet-bootstrap.md"

# Copy 5 protocol templates (handoff / review / git / conduct / knowledge)
if [ -d "$SCRIPT_DIR/protocols" ]; then
  cp "$SCRIPT_DIR/protocols/handoff.md" "$TARGET/.kiro/steering/protocol/handoff.md"
  cp "$SCRIPT_DIR/protocols/review.md" "$TARGET/.kiro/steering/protocol/review.md"
  cp "$SCRIPT_DIR/protocols/git.md" "$TARGET/.kiro/steering/protocol/git.md"
  cp "$SCRIPT_DIR/protocols/conduct.md" "$TARGET/.kiro/steering/protocol/conduct.md"
  cp "$SCRIPT_DIR/protocols/knowledge.md" "$TARGET/.kiro/steering/protocol/knowledge.md"
  echo "  - 5 protocol templates copied"
else
  echo "  WARN: protocols/ subdir not found, manually copy from BOOTSTRAP.md §7"
fi

# Copy fleet-status.sh
if [ -f "$SCRIPT_DIR/scripts/fleet-status.sh" ]; then
  cp "$SCRIPT_DIR/scripts/fleet-status.sh" "$TARGET/scripts/fleet-status.sh"
  chmod +x "$TARGET/scripts/fleet-status.sh"
  echo "  - fleet-status.sh copied + chmod +x"
else
  echo "  WARN: scripts/fleet-status.sh not found"
fi
echo "OK"

# ─── Step 4: Install claude-memory-compiler (long-term memory) ───────────
echo ""
echo "[4/7] Installing claude-memory-compiler..."
SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$SKILLS_DIR"
if [ ! -d "$SKILLS_DIR/claude-memory-compiler" ]; then
  git clone https://github.com/coleam00/claude-memory-compiler "$SKILLS_DIR/claude-memory-compiler"
  cd "$SKILLS_DIR/claude-memory-compiler"

  # PEP 668 detection (macOS new Python blocks system pip)
  if python3 -c "import sys; sys.exit(0 if sys.prefix != sys.base_prefix else 1)" 2>/dev/null; then
    # Inside a venv — safe to install
    pip install -e . && echo "  - installed in venv"
  elif command -v pipx >/dev/null 2>&1; then
    pipx install -e . && echo "  - installed via pipx"
  else
    echo "  WARN: no venv + no pipx detected"
    echo "  Try one of:"
    echo "    a) python3 -m venv .venv && source .venv/bin/activate && pip install -e ."
    echo "    b) pipx install -e .  (install pipx first: brew/apt/etc)"
    echo "    c) pip install -e . --break-system-packages  (override PEP 668)"
    pip install -e . --break-system-packages 2>/dev/null || python3 -m pip install -e . --break-system-packages 2>/dev/null || {
      echo "  ERROR: pip install failed. Manually run from $SKILLS_DIR/claude-memory-compiler"
    }
  fi
  cd - >/dev/null
else
  echo "  - already installed"
fi
echo "OK"

# ─── Step 5: Configure Playwright MCP (auto-merge into ~/.claude.json) ───
echo ""
echo "[5/7] Configuring Playwright MCP..."
CLAUDE_CONFIG="$HOME/.claude.json"
if [ ! -f "$CLAUDE_CONFIG" ]; then
  echo "  WARN: ~/.claude.json not found. Skipping (Claude Code will create on first launch)"
elif grep -q '"playwright"' "$CLAUDE_CONFIG" 2>/dev/null; then
  echo "  - already configured"
elif command -v jq >/dev/null 2>&1; then
  jq '.mcpServers.playwright = {"command": "npx", "args": ["@playwright/mcp@latest"]}' \
    "$CLAUDE_CONFIG" > "$CLAUDE_CONFIG.tmp" && mv "$CLAUDE_CONFIG.tmp" "$CLAUDE_CONFIG"
  echo "  - added via jq"
else
  echo "  WARN: jq not found. Manually add to ~/.claude.json mcpServers:"
  echo '    "playwright": { "command": "npx", "args": ["@playwright/mcp@latest"] }'
fi
echo "OK"

# ─── Step 6: Detect ECC skills location (plugin form vs standalone) ──────
echo ""
echo "[6/7] Detecting ECC skills..."
ECC_SKILLS=""
if [ -d "$HOME/.claude/plugins" ]; then
  ECC_SKILLS=$(find "$HOME/.claude/plugins" -type d -name "skills" -path "*everything-claude-code*" 2>/dev/null | head -1)
fi
if [ -z "$ECC_SKILLS" ] && [ -d "$HOME/.claude/skills" ]; then
  ECC_SKILLS="$HOME/.claude/skills"
fi
if [ -n "$ECC_SKILLS" ]; then
  echo "  ECC skills location: $ECC_SKILLS"
  for skill in blueprint claude-devfleet ralphinho-rfc-pipeline santa-loop brainstorming; do
    if [ -d "$ECC_SKILLS/$skill" ]; then
      echo "  ✓ $skill"
    else
      echo "  ✗ $skill (missing — run /configure-ecc in Claude Code to install)"
    fi
  done
else
  echo "  WARN: ECC skills not found in ~/.claude/plugins/ or ~/.claude/skills/"
  echo "  Run /configure-ecc in Claude Code to install"
fi
echo "OK"

# ─── Step 7: Done ────────────────────────────────────────────────────────
echo ""
echo "[7/7] Bootstrap skeleton ready."
echo ""
echo "Next steps:"
echo "1. cd $TARGET"
echo "2. Start Claude Code"
echo "3. Give Claude this prompt:"
echo ""
echo "   You are the new project zeus session. Read .kiro/templates/olympus-fleet-bootstrap.md fully."
echo "   Follow sections 1-14 in order. Report after each step. Ask user when stuck."
echo "   Do not autonomously decide business direction."
echo ""
echo "Done."
