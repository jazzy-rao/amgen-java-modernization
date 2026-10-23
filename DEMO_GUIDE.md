# Demo Guide: Java Modernization with IBM Bob

## Overview

This demo moves a fictional lab sample tracker from **Oracle JDK 17** to **Red Hat build of OpenJDK 17**, with IBM Bob's Java Modernization workflow guiding the assessment. The Oracle JDK 17 baseline runs on **macOS arm64**. The Red Hat OpenJDK 17 target runs on an **IBM Cloud VPC VM running RHEL 9.6**.

---

## Runtime environments

| Role | Environment | JDK | Vendor string |
|---|---|---|---|
| **Before** (baseline) | macOS arm64 (your laptop) | Oracle JDK 17 | `Oracle Corporation` |
| **After** (target) | RHEL 9.6 on IBM Cloud VPC VM | Red Hat build of OpenJDK 17 | `Red Hat, Inc.` |

> **Why a RHEL VM, not a second JDK on macOS?**
> Red Hat does not publish a native macOS arm64 build of OpenJDK. To demonstrate an actual Red Hat JDK with its authentic vendor string and environment, the demo uses an IBM Cloud VPC VM running RHEL 9.6. This also reflects a realistic Amgen target environment more accurately than a macOS simulation would.

> **The scripts/run-temurin17.sh script** remains available as an alternative macOS migration target (Eclipse Temurin 17, an equivalent upstream OpenJDK build), but is not the primary demo path. The RHEL VM with Red Hat OpenJDK 17 is the target for this demo.

---

## Build configuration

| Item | Value |
|---|---|
| Java target | 17 (`<java.version>17</java.version>` in `pom.xml`, applied via `maven.compiler.release`) |
| Build tool | Maven 3.9+ |
| Test framework | JUnit Jupiter 5.10.2 |
| Plugins | maven-compiler 3.12.1, surefire 3.2.5, jar 3.3.0 |
| Dependencies | JUnit only (test scope) |
| Runtime dependencies | none |

---

## Project structure

```
pom.xml
README.md
DEMO_GUIDE.md
DEMO_SCRIPT.md
demo/index.html              5-section dashboard (open in a browser)
demo/results.js              YOUR hand-edited results (reset clears it)
demo/results.template.js     blank results; reset copies this over results.js
demo/evidence/
  README.txt                 instructions for evidence files
  before-java-version.txt    Oracle JDK 17: java -version  ← populated by capture-baseline.sh
  before-mvn-version.txt     Oracle JDK 17: mvn -version   ← populated by capture-baseline.sh
  before-build.txt           Oracle JDK 17: mvn clean verify output ← populated
  before-app.txt             Oracle JDK 17: demo app output ← populated
  after-java-version.txt     RHEL VM: java -version (placeholder — run validate-rhel.sh on the VM)
  after-build.txt            RHEL VM: mvn clean verify output (placeholder)
  after-app.txt              RHEL VM: demo app output (placeholder)
scripts/reset-demo.sh        reset (macOS/Linux)
scripts/reset-demo.ps1       reset (Windows PowerShell)
scripts/run-oracle17.sh      build+run with Oracle JDK 17 (auto-locates)
scripts/run-temurin17.sh     build+run with Eclipse Temurin 17 (macOS alternative)
scripts/capture-baseline.sh  capture Oracle JDK 17 evidence to demo/evidence/
scripts/validate-rhel.sh     validate on Red Hat OpenJDK 17 (run on RHEL VM)
src/main/java/com/amgen/demo/sample/{DemoApp,SampleService,LabSample,SampleStatus}.java
src/test/java/com/amgen/demo/sample/SampleServiceTest.java
```

---

## How the baseline is saved

The original working project is protected by the annotated Git tag **`demo-baseline`**.

- Reset restores `pom.xml` and `src/` from that tag, resets `demo/results.js` from its template, and deletes `target/`.
- Reset never touches `.git`, `README.md`, `DEMO_GUIDE.md`, `DEMO_SCRIPT.md`, `demo/index.html`, `scripts/`, `demo/evidence/`, or anything outside this folder.
- Reset never commits, never runs Maven or Bob, and never starts a migration.
- If files differ from the baseline, reset lists them and requires you to type `reset` before overwriting anything.
- To inspect the baseline: `git show demo-baseline --stat`.
- To update the baseline deliberately: `git tag -f -a demo-baseline <commit> -m "..."`.

---

## Presentation checklist

### 2a. Install prerequisites — macOS (one-time)

**Maven:**
```bash
brew install maven
mvn -version   # expect: Apache Maven 3.9+
```

**Oracle JDK 17** (manual download required):
1. Go to: https://www.oracle.com/java/technologies/downloads/archive/
2. Click **Java 17**, then **macOS**, then download the **ARM64 Compressed Archive** (`jdk-17.0.x_macos-aarch64_bin.tar.gz`) or the **ARM64 Installer** (`.dmg`)
3. Accept the Oracle No-Fee Terms and Conditions license (no account required)
4. If you downloaded the `.tar.gz`: `mkdir -p ~/Library/Java/JavaVirtualMachines && tar -xzf jdk-17.0.x_macos-aarch64_bin.tar.gz -C ~/Library/Java/JavaVirtualMachines/`
5. Verify: `/usr/libexec/java_home -V` should now list an Oracle entry for 17

After installation:
```bash
/usr/libexec/java_home -V
# Must include:
#   17.0.x (arm64) "Oracle Corporation" - "Java SE 17.0.x"
```

### 2b. Install prerequisites — RHEL 9.6 VM (one-time)

SSH into the VM and run:

```bash
sudo dnf install java-17-openjdk-devel maven
java -version   # must show: OpenJDK Runtime Environment (Red Hat) ...
mvn -version    # check the runtime: line shows Red Hat path
```

### 2c. Copy project source to the VM (if not already there)

From macOS, in the project root:

```bash
scp -i ssh_private_key.pem -r . root@<VM_IP>:~/java-modernization-demo/
```

Or use `rsync` for incremental updates after Bob makes changes:

```bash
rsync -avz -e "ssh -i ssh_private_key.pem" . root@<VM_IP>:~/java-modernization-demo/ \
  --exclude=.git --exclude=target --exclude=.DS_Store
```

### 3. Reset the project

```bash
./scripts/reset-demo.sh          # macOS/Linux
pwsh ./scripts/reset-demo.ps1    # Windows (PowerShell 7)
```

Lists anything it will overwrite and asks you to type `reset`.

### 4. Verify the Oracle JDK baseline

```bash
./scripts/run-oracle17.sh
```

Or, optionally capture the evidence to files:

```bash
./scripts/capture-baseline.sh
# Writes demo/evidence/before-*.txt
```

Alternatively, set manually:
```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 17 --vendor Oracle)
export PATH="$JAVA_HOME/bin:/opt/homebrew/bin:$PATH"
java -version   # must show Oracle Corporation
mvn -version    # check vendor: Oracle Corporation
mvn clean verify
java -jar target/java-modernization-demo-1.0.0.jar
```

Capture: vendor/version output, `Tests run: 8, Failures: 0`, and the demo's Java vendor/version/home lines.

### 5. Open the dashboard

```bash
open demo/index.html             # macOS
xdg-open demo/index.html         # Linux
```

The **Before** panel is already populated — `demo/results.js` was filled in with real Oracle JDK 17 values captured by `./scripts/capture-baseline.sh` on 2026-10-23. You should see:

- Vendor: `Oracle Corporation`
- Version: `17.0.20.1`
- Build: ✓ Passed
- Tests: ✓ Passed (8 run, 0 failures)

If the panel shows "Not yet verified", the file was reset. Re-run `./scripts/capture-baseline.sh` and update the `before` block in `demo/results.js` with the values it prints.

The **After** panel remains blank until you run `validate-rhel.sh` on the RHEL VM and fill in the `after` block (Step 9).

### 6. Run IBM Bob's Java Modernization workflow

Open this folder in IBM Bob and use the Java Modernization workflow.

Suggested prompt:
> Assess this project for migration from Oracle JDK 17 to Red Hat build of OpenJDK 17 and report any real compatibility concerns.

### 7. Review Bob's assessment and any changes

```bash
git status
git diff
```

Copy what Bob actually reported into `assessment` and `changes` in `demo/results.js`. If Bob reports no concerns or no file changes, record exactly that.

### 8. Copy any Bob-applied changes to the RHEL VM

If Bob changed any files and you accepted them:

```bash
# From macOS:
rsync -avz -e "ssh -i ssh_private_key.pem" . root@<VM_IP>:~/java-modernization-demo/ \
  --exclude=.git --exclude=target --exclude=.DS_Store
```

If no files were changed, skip this step.

### 9. Validate on the RHEL 9.6 VM

SSH into the VM:

```bash
cd ~/java-modernization-demo
./scripts/validate-rhel.sh
```

The script prints a summary at the end with the exact values to paste into `demo/results.js`. Save the full output if you want to archive it in `demo/evidence/after-build.txt`.

### 10. Update the dashboard with actual results

Edit the `after` block in `demo/results.js`, plus `assessment`, `changes`, and `updated`. Refresh the browser.

The outcome banner turns green only when both target build and tests are Passed on a Red Hat runtime.

### 11. Reset for the next presentation

```bash
./scripts/reset-demo.sh
```

If Bob committed anything, the reset restores `pom.xml` and `src/` to the baseline in the working tree. Extra commits stay in Git history.

---

## Files to show during the presentation

1. `demo/index.html` (dashboard) — the primary visual
2. `demo/results.js` — the hand-edited results file (shows the evidence is manual)
3. Bob's assessment output and `git diff` (what Bob found and what it changed, if anything)
4. Terminal output from `./scripts/run-oracle17.sh` and `./scripts/validate-rhel.sh`

Code is not walked through during the presentation — the focus is assessment, Bob's assistance, and verified results.

---

## Evidence to capture

**Before (Oracle JDK 17 on macOS):**
- `java -version` and `mvn -version` output
- `mvn clean verify` result: 8 tests, 0 failures
- Demo app output (`java -jar ...`)
- Class file level: `javap -v -cp target/classes com.amgen.demo.sample.DemoApp | grep "major version"` (expect 61)

**After (Red Hat OpenJDK 17 on RHEL 9.6):**
- Same commands as above, from the RHEL VM terminal
- The vendor string should change from `Oracle Corporation` to `Red Hat, Inc.`
- Source changes should be none (unless Bob identified a genuine Oracle-specific issue)

After migration, compare the two sets of output. The vendor and `java.home` lines are expected to change. Source changes are not necessarily expected for an application that uses only standard Java APIs.
