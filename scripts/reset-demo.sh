#!/usr/bin/env bash
# Reset the demo project to the protected Git baseline (tag: demo-baseline).
#
# What it restores (from the tag):   pom.xml, src/
# What it also resets:               demo/results.js  <- demo/results.template.js
#                                    target/          (Maven build output, deleted)
# What it never touches:             .git, README.md, DEMO_GUIDE.md, demo/index.html, scripts/,
#                                    and any other file. Nothing outside this project directory.
# It never commits, never runs Maven/Bob, and never triggers a migration.
set -euo pipefail

BASELINE_TAG="demo-baseline"
RESTORE_PATHS=(pom.xml src)

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$ROOT"

# --- safety checks -----------------------------------------------------------
command -v git >/dev/null || { echo "ERROR: git is required." >&2; exit 1; }
TOP="$(git rev-parse --show-toplevel 2>/dev/null | { read -r p; cd "$p" 2>/dev/null && pwd -P; } || true)"
[ "$TOP" = "$ROOT" ] || { echo "ERROR: $ROOT is not the root of its own Git repository. Aborting." >&2; exit 1; }
git rev-parse -q --verify "refs/tags/$BASELINE_TAG" >/dev/null ||
  { echo "ERROR: baseline tag '$BASELINE_TAG' not found. Aborting; nothing was changed." >&2; exit 1; }
[ -f demo/results.template.js ] || { echo "ERROR: demo/results.template.js missing. Aborting." >&2; exit 1; }

echo "Demo reset"
echo "  Project : $ROOT"
echo "  Baseline: tag '$BASELINE_TAG' ($(git rev-parse --short "$BASELINE_TAG^{commit}"))"
echo

# --- detect what differs from the baseline ----------------------------------
CHANGED="$(git diff --name-status "$BASELINE_TAG" -- "${RESTORE_PATHS[@]}")"   # tracked: modified/added/deleted
UNTRACKED="$(git ls-files --others --exclude-standard -- "${RESTORE_PATHS[@]}")"
RESULTS_EDITED=no
if [ -f demo/results.js ] && ! cmp -s demo/results.js demo/results.template.js; then RESULTS_EDITED=yes; fi
[ -f demo/results.js ] || RESULTS_EDITED=missing

if [ -n "$CHANGED" ] || [ -n "$UNTRACKED" ] || [ "$RESULTS_EDITED" = yes ]; then
  echo "These files differ from the baseline and WILL BE OVERWRITTEN OR DELETED:"
  [ -n "$CHANGED" ]   && echo "$CHANGED"   | sed 's/^/  /'
  [ -n "$UNTRACKED" ] && echo "$UNTRACKED" | sed 's/^/  ?\t(untracked, will be deleted) /'
  [ "$RESULTS_EDITED" = yes ] && echo "  M	demo/results.js (recorded demo results will be cleared)"
  echo
  printf "Type 'reset' to continue, anything else cancels: "
  read -r ANSWER || ANSWER=""
  [ "$ANSWER" = "reset" ] || { echo "Cancelled. Nothing was changed."; exit 1; }
else
  echo "Project already matches the baseline. Refreshing results and build output only."
fi

# --- restore ------------------------------------------------------------------
git restore --source="$BASELINE_TAG" --staged --worktree -- "${RESTORE_PATHS[@]}"
# Delete untracked files only inside the restored paths (never anywhere else).
git clean -fdq -- "${RESTORE_PATHS[@]}"
cp demo/results.template.js demo/results.js
if [ -d target ] && [ ! -L target ]; then rm -rf -- "$ROOT/target"; fi

# --- report -------------------------------------------------------------------
echo
echo "Reset complete."
OTHER="$(git status --porcelain -- . ":(exclude)demo/results.js" | grep -vE '^\s*\S+\s+(pom\.xml|src/)' || true)"
if [ -n "$OTHER" ]; then
  echo "Note: these other changes exist and were left untouched:"
  echo "$OTHER" | sed 's/^/  /'
fi
echo "Next: mvn clean verify   (see DEMO_GUIDE.md)"
