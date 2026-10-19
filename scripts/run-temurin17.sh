#!/usr/bin/env bash
# Run the demo app with Eclipse Temurin 17 (OpenJDK 17 - Adoptium build).
#
# Usage: ./scripts/run-temurin17.sh [maven|app|version]
#   maven   - print Maven version info (shows Java vendor/runtime Maven is using)
#   app     - run the demo app JAR (requires a prior build)
#   version - print java -version and java.vendor property
#   (no arg) - build (mvn clean verify) then run the demo app
#
# This script DOES NOT change your system's default Java or JAVA_HOME permanently.
# All changes are scoped to this script's shell session only.
#
# PREREQUISITE: Eclipse Temurin 17 must be installed.
# Install with: brew install --cask temurin@17
#   (one-time sudo prompt for the .pkg installer; no account or license click needed)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$ROOT"

# ── Locate Eclipse Temurin 17 ─────────────────────────────────────────────────
# Note: /usr/libexec/java_home --vendor is not supported on all macOS versions;
# we always use the release file to verify vendor and version.
TEMURIN_HOME=""

# Scan system and user-local JVM directories for an Adoptium JDK 17 release file
for search_base in /Library/Java/JavaVirtualMachines "$HOME/Library/Java/JavaVirtualMachines"; do
  [ -d "$search_base" ] || continue
  for dir in "$search_base"/*.jdk; do
    [ -d "$dir/Contents/Home" ] || continue
    release="$dir/Contents/Home/release"
    [ -f "$release" ] || continue
    if grep -q 'IMPLEMENTOR="Eclipse Adoptium"' "$release" && grep -q 'JAVA_VERSION="17' "$release"; then
      TEMURIN_HOME="$dir/Contents/Home"
      break 2
    fi
  done
done

if [ -z "$TEMURIN_HOME" ]; then
  echo ""
  echo "ERROR: Eclipse Temurin 17 not found on this machine."
  echo ""
  echo "Install it with:"
  echo "  brew install --cask temurin@17"
  echo "  (will prompt for sudo password once for the .pkg installer)"
  echo ""
  echo "After installation, re-run this script."
  echo ""
  exit 1
fi

export JAVA_HOME="$TEMURIN_HOME"
export PATH="$JAVA_HOME/bin:$PATH"

# ── Locate Maven ──────────────────────────────────────────────────────────────
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

# ── Helpers ───────────────────────────────────────────────────────────────────
print_java_info() {
  echo ""
  echo "=== Java runtime ==="
  "$JAVA_HOME/bin/java" -version 2>&1
  echo "JAVA_HOME : $JAVA_HOME"
  echo "java.vendor: $("$JAVA_HOME/bin/java" -XshowSettings:property -version 2>&1 | grep java.vendor | head -1 | sed 's/.*= //')"
  echo ""
}

# ── Dispatch ─────────────────────────────────────────────────────────────────
ACTION="${1:-build-and-run}"

case "$ACTION" in
  version)
    print_java_info
    ;;
  maven)
    print_java_info
    echo "=== Maven version ==="
    $MVN -version
    echo ""
    ;;
  app)
    JAR="target/java-modernization-demo-1.0.0.jar"
    if [ ! -f "$JAR" ]; then
      echo "ERROR: $JAR not found. Run without args first to build."
      exit 1
    fi
    print_java_info
    echo "=== Demo app ==="
    "$JAVA_HOME/bin/java" -jar "$JAR"
    ;;
  build-and-run)
    print_java_info
    echo "=== Maven version ==="
    $MVN -version
    echo ""
    echo "=== Build and test ==="
    $MVN clean verify
    echo ""
    echo "=== Demo app ==="
    "$JAVA_HOME/bin/java" -jar "target/java-modernization-demo-1.0.0.jar"
    ;;
  *)
    echo "Usage: $0 [version|maven|app|build-and-run]"
    exit 1
    ;;
esac
