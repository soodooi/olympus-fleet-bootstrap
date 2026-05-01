#!/usr/bin/env bash
# fleet-status.sh — print active handoffs + worktree state
# Usage: bash scripts/fleet-status.sh

set -e

cd "$(git rev-parse --show-toplevel)"

echo "=== Olympus Fleet Status ==="
echo ""

# 1. Worktree state
echo "[Worktrees]"
git worktree list 2>/dev/null | sed 's|^|  |' || echo "  (no worktrees)"
echo ""

# 2. Active handoff count
HANDOFF_DIR=".kiro/handoffs"
if [ ! -d "$HANDOFF_DIR" ]; then
  echo "[Handoffs] no .kiro/handoffs/ dir"
  exit 0
fi

echo "[Handoff status counts]"
for status in open claimed in_progress done verified cancelled; do
  n=$(grep -l "^status: $status$" $HANDOFF_DIR/H-*.md 2>/dev/null | wc -l | tr -d ' ')
  printf "  %-12s %s\n" "$status" "$n"
done
echo ""

# 3. Active handoffs (open / claimed / in_progress)
echo "[Active handoffs]"
for f in $HANDOFF_DIR/H-*.md; do
  [ -f "$f" ] || continue
  status=$(grep "^status:" "$f" | head -1 | awk '{print $2}')
  case "$status" in
    open|claimed|in_progress)
      id=$(grep "^id:" "$f" | head -1 | awk '{print $2}')
      severity=$(grep "^severity:" "$f" | head -1 | awk '{print $2}')
      assigned=$(grep "^assigned_to:" "$f" | head -1 | awk '{print $2}')
      title=$(grep "^title:" "$f" | head -1 | sed 's/^title: //' | cut -c1-60)
      printf "  %-22s [%s] (%-11s) →%-12s %s\n" "$id" "$severity" "$status" "$assigned" "$title"
      ;;
  esac
done
echo ""

# 4. Branch state (main vs origin)
echo "[Branch state]"
current=$(git branch --show-current)
ahead=$(git rev-list --count origin/main..HEAD 2>/dev/null || echo "?")
behind=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo "?")
printf "  current: %s (ahead=%s, behind=%s)\n" "$current" "$ahead" "$behind"

# 5. Open PRs (if gh available)
if command -v gh >/dev/null 2>&1; then
  echo ""
  echo "[Open PRs]"
  gh pr list --state open --limit 10 2>/dev/null | sed 's|^|  |' || echo "  (gh fail or no PRs)"
fi
