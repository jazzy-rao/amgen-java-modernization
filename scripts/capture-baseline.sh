#!/usr/bin/env bash
# capture-baseline.sh
#
# Capture Oracle JDK 17 baseline evidence into demo/evidence/.
# Run this on macOS before the demo to pre-populate the evidence directory.
#
# What it records:
#   demo/evidence/before-java-version.txt   java -version output
#   demo/evidence/before-mvn-version.txt    mvn -version output
#   demo/evidence/before-build.txt          mvn clean verify output (last 30 lines)
#   demo/evidence/before-app.txt            demo JAR output
#
# Usage:
#   ./scripts/capture-baseline.sh
#
# Requires Oracle JDK 17 installed (see README.md).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$ROOT"

EVIDENCE_DIR="demo/evidence"
mkdir -p "$EVIDENCE_DIR"

# ── Locate Oracle JDK 17 (same logic as run-oracle17.sh) ─────────────────────
ORACLE_HOME=""
for search_base in /Library/Java/JavaVirtualMachines "$HOME/Library/Java/JavaVirtualMachines"; do
  [ -d "$search_base" ] || continue
  for dir in "$search_base"/*.jdk "$search_base"/jdk-*.jdk; do
    [ -d "$dir/Contents/Home" ] || continue
    release="$dir/Contents/Home/release"
    [ -f "$release" ] || continue
    if grep -q 'IMPLEMENTOR="Oracle Corporation"' "$release" && grep -q 'JAVA_VERSION="17' "$release"; then
      ORACLE_HOME="$dir/Contents/Home"
      break 2
    fi
  done
done

if [ -z "$ORACLE_HOME" ]; then
  echo "ERROR: Oracle JDK 17 not found. See README.md for install instructions."
  exit 1
fi

export JAVA_HOME="$ORACLE_HOME"
export PATH="$JAVA_HOME/bin:$PATH"

MVN=""
if command -v mvn &>/dev/null; then
  MVN=mvn
elif [ -x /opt/homebrew/bin/mvn ]; then
  MVN=/opt/homebrew/bin/mvn
  export PATH="/opt/homebrew/bin:$PATH"
fi
if [ -z "$MVN" ]; then
  echo "ERROR: mvn not found. Install with: brew install maven"
  exit 1
fi

TS=$(date '+%Y-%m-%d %H:%M %Z')
echo "Capturing Oracle JDK 17 baseline evidence..."
echo "Timestamp: $TS"
echo ""

# java -version
echo "--- java -version ---"
"$JAVA_HOME/bin/java" -version 2>&1 | tee "$EVIDENCE_DIR/before-java-version.txt"
echo "" >> "$EVIDENCE_DIR/before-java-version.txt"
echo "Captured: $TS" >> "$EVIDENCE_DIR/before-java-version.txt"
echo ""

# mvn -version
echo "--- mvn -version ---"
$MVN -version 2>&1 | tee "$EVIDENCE_DIR/before-mvn-version.txt"
echo "" >> "$EVIDENCE_DIR/before-mvn-version.txt"
echo "Captured: $TS" >> "$EVIDENCE_DIR/before-mvn-version.txt"
echo ""

# mvn clean verify
echo "--- mvn clean verify ---"
BUILD_LOG=$(mktemp)
BUILD_EXIT=0
$MVN clean verify 2>&1 | tee "$BUILD_LOG" || BUILD_EXIT=$?
# Save last 50 lines (contains test results and BUILD SUCCESS/FAILURE)
tail -50 "$BUILD_LOG" > "$EVIDENCE_DIR/before-build.txt"
echo "" >> "$EVIDENCE_DIR/before-build.txt"
echo "Captured: $TS" >> "$EVIDENCE_DIR/before-build.txt"
rm -f "$BUILD_LOG"
echo ""

# Demo app
if [ $BUILD_EXIT -eq 0 ] && [ -f "target/java-modernization-demo-1.0.0.jar" ]; then
  echo "--- Demo app ---"
  "$JAVA_HOME/bin/java" -jar "target/java-modernization-demo-1.0.0.jar" 2>&1 | \
    tee "$EVIDENCE_DIR/before-app.txt"
  echo "" >> "$EVIDENCE_DIR/before-app.txt"
  echo "Captured: $TS" >> "$EVIDENCE_DIR/before-app.txt"
else
  echo "Build failed (exit $BUILD_EXIT) — skipping app run."
  echo "Build failed — app not captured." > "$EVIDENCE_DIR/before-app.txt"
fi
echo ""

echo "Evidence written to $EVIDENCE_DIR/"
ls -1 "$EVIDENCE_DIR"/before-*.txt
echo ""
echo "Next: update demo/results.js with the captured values, then refresh demo/index.html"
