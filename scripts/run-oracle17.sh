#!/usr/bin/env bash
# Run the demo app with Oracle JDK 17.
#
# Usage: ./scripts/run-oracle17.sh [maven|app|version]
#   maven   - print Maven version info (shows Java vendor/runtime Maven is using)
#   app     - run the demo app JAR (requires a prior build)
#   version - print java -version and java.vendor property
#   (no arg) - build (mvn clean verify) then run the demo app
#
# This script DOES NOT change your system's default Java or JAVA_HOME permanently.
# All changes are scoped to this script's shell session only.
#
# PREREQUISITE: Oracle JDK 17 must be installed at one of the paths this script checks.
# Install from: https://www.oracle.com/java/technologies/downloads/archive/
#   -> Java 17 -> macOS -> ARM64 DMG or PKG
#   (macOS, no account required; accept the Oracle No-Fee Terms and Conditions license)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$ROOT"

# ── Locate Oracle JDK 17 ──────────────────────────────────────────────────────
# Oracle installs to /Library/Java/JavaVirtualMachines/jdk-17.*.jdk on macOS.
# Note: /usr/libexec/java_home --vendor is not supported on all macOS versions;
# we always use the release file to verify the vendor.
ORACLE_HOME=""

# Scan system and user-local JVM directories for an Oracle JDK 17 release file
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
  echo ""
  echo "ERROR: Oracle JDK 17 not found on this machine."
  echo ""
  echo "Install it from the Oracle archive (no account required):"
  echo "  https://www.oracle.com/java/technologies/downloads/archive/"
  echo "  -> Java 17 -> macOS -> ARM64 Compressed Archive or Installer"
  echo "  Accept the Oracle No-Fee Terms and Conditions license during install."
  echo ""
  echo "After installation, re-run this script."
  echo ""
  echo "Typical install path: /Library/Java/JavaVirtualMachines/jdk-17.0.x.jdk/Contents/Home"
  exit 1
fi

export JAVA_HOME="$ORACLE_HOME"
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
