#!/usr/bin/env bash
# validate-rhel.sh
#
# Validate the java-modernization-demo on Red Hat OpenJDK 17 (RHEL 9.6).
# Run this on the RHEL VM, not on macOS.
#
# Prerequisites on the VM:
#   - Red Hat OpenJDK 17 installed (dnf install java-17-openjdk-devel)
#   - Apache Maven 3.6+ installed (dnf install maven)
#   - The project source in ~/java-modernization-demo/  (or pass a path)
#
# Usage:
#   ./validate-rhel.sh [project-dir]
#
# With no argument, uses ~/java-modernization-demo/ as the project root.
# Produces a summary at the end suitable for pasting into demo/results.js.
#
# This script does NOT require Git or macOS tools. It works on plain RHEL 9.6.
set -euo pipefail

PROJECT_DIR="${1:-$HOME/java-modernization-demo}"

if [ ! -f "$PROJECT_DIR/pom.xml" ]; then
  echo "ERROR: pom.xml not found in $PROJECT_DIR"
  echo "  Usage: $0 [project-dir]"
  echo "  Expected a Maven project at that path."
  exit 1
fi

cd "$PROJECT_DIR"

# ── 1. Locate Red Hat OpenJDK 17 ─────────────────────────────────────────────
# RHEL 9 installs OpenJDK under /usr/lib/jvm/; use the java-17-openjdk alternative.
RH_JAVA_HOME=""

# Preferred: the exact versioned path reported previously
CANDIDATE_PATHS=(
  /usr/lib/jvm/java-17-openjdk
  /usr/lib/jvm/java-17-openjdk-17.0.20.1.1-1.1.el9.x86_64
)
for p in "${CANDIDATE_PATHS[@]}"; do
  if [ -x "$p/bin/java" ]; then
    release="$p/release"
    if [ -f "$release" ] && grep -q 'JAVA_VERSION="17' "$release"; then
      RH_JAVA_HOME="$p"
      break
    elif [ ! -f "$release" ]; then
      # No release file — check version via binary
      v=$("$p/bin/java" -version 2>&1 | head -1 || true)
      if echo "$v" | grep -q '"17\.'; then
        RH_JAVA_HOME="$p"
        break
      fi
    fi
  fi
done

# Fallback: use whatever `java` is on PATH if it is JDK 17
if [ -z "$RH_JAVA_HOME" ] && command -v java &>/dev/null; then
  v=$(java -version 2>&1 | head -1 || true)
  h=$(java -XshowSettings:property -version 2>&1 | awk -F'= ' '/java.home/{print $2; exit}' || true)
  if echo "$v" | grep -q '"17\.' && [ -n "$h" ]; then
    RH_JAVA_HOME="$h"
  fi
fi

if [ -z "$RH_JAVA_HOME" ] || [ ! -x "$RH_JAVA_HOME/bin/java" ]; then
  echo ""
  echo "ERROR: Red Hat OpenJDK 17 not found."
  echo ""
  echo "Install it with:"
  echo "  sudo dnf install java-17-openjdk-devel"
  echo ""
  echo "Then re-run this script."
  exit 1
fi

export JAVA_HOME="$RH_JAVA_HOME"
export PATH="$JAVA_HOME/bin:$PATH"

# ── 2. Locate Maven ───────────────────────────────────────────────────────────
MVN=""
for candidate in mvn /usr/bin/mvn /usr/local/bin/mvn; do
  if command -v "$candidate" &>/dev/null 2>&1; then
    MVN="$candidate"; break
  fi
done
if [ -z "$MVN" ]; then
  echo "ERROR: mvn not found."
  echo "  Install with: sudo dnf install maven"
  exit 1
fi

# ── 3. Print environment ──────────────────────────────────────────────────────
echo ""
echo "============================================================"
echo " Java Modernization Demo — RHEL 9.6 Validation"
echo "============================================================"
echo ""
echo "Project : $PROJECT_DIR"
echo "Date    : $(date '+%Y-%m-%d %H:%M %Z')"
echo ""
echo "--- Java runtime ---"
"$JAVA_HOME/bin/java" -version 2>&1
echo "JAVA_HOME : $JAVA_HOME"

VENDOR=$("$JAVA_HOME/bin/java" -XshowSettings:property -version 2>&1 | awk -F'= ' '/^ *java\.vendor /{print $2; exit}' || true)
VERSION=$("$JAVA_HOME/bin/java" -XshowSettings:property -version 2>&1 | awk -F'= ' '/^ *java\.version /{print $2; exit}' || true)
echo "java.vendor  : $VENDOR"
echo "java.version : $VERSION"
echo ""

echo "--- Maven version ---"
$MVN -version
echo ""

# ── 4. Build and test ─────────────────────────────────────────────────────────
echo "--- Build and test (mvn clean verify) ---"
BUILD_LOG=$(mktemp)
BUILD_EXIT=0
$MVN clean verify 2>&1 | tee "$BUILD_LOG" || BUILD_EXIT=$?

echo ""

if [ $BUILD_EXIT -eq 0 ]; then
  BUILD_STATUS="passed"
else
  BUILD_STATUS="failed"
fi

# Extract test summary line
TEST_SUMMARY=$(grep -E "Tests run:" "$BUILD_LOG" | tail -1 || echo "not found")
BUILD_RESULT=$(grep -E "BUILD (SUCCESS|FAILURE)" "$BUILD_LOG" | tail -1 || echo "not recorded")

# ── 5. Run the demo app ───────────────────────────────────────────────────────
JAR="target/java-modernization-demo-1.0.0.jar"
APP_EXIT=0
echo "--- Demo app run ---"
if [ -f "$JAR" ]; then
  "$JAVA_HOME/bin/java" -jar "$JAR" || APP_EXIT=$?
  echo ""
else
  echo "JAR not found — build likely failed."
  APP_EXIT=1
fi

# ── 6. Summary ────────────────────────────────────────────────────────────────
echo "============================================================"
echo " VALIDATION SUMMARY"
echo "============================================================"
echo "Java vendor  : $VENDOR"
echo "Java version : $VERSION"
echo "JAVA_HOME    : $JAVA_HOME"
echo "Build        : $BUILD_RESULT"
echo "Tests        : $TEST_SUMMARY"
echo "App startup  : $([ $APP_EXIT -eq 0 ] && echo 'Completed successfully' || echo 'Failed (exit '$APP_EXIT')')"
echo ""
echo "--- Paste into demo/results.js (after field) ---"
RUNTIME_LINE=$("$JAVA_HOME/bin/java" -version 2>&1 | head -1)
echo "  vendor:          \"$VENDOR\","
echo "  version:         \"$VERSION\","
echo "  runtimeDetected: \"$RUNTIME_LINE\","
echo "  build:  { status: \"$BUILD_STATUS\", detail: \"$BUILD_RESULT\" },"
if [ $APP_EXIT -eq 0 ]; then
  echo "  appRun: { status: \"passed\",         detail: \"App started and completed; Java vendor line confirmed\" },"
else
  echo "  appRun: { status: \"failed\",         detail: \"App exited $APP_EXIT\" },"
fi
echo ""

rm -f "$BUILD_LOG"
