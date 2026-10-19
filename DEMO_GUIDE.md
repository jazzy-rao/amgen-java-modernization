# Demo Guide: Java Modernization Baseline

## Runtime environment

This demo runs on **macOS arm64** (Apple Silicon). Two JDK 17 builds are used:

| Role | Distribution | Vendor string | How to install |
|---|---|---|---|
| **Before** (baseline) | Oracle JDK 17 | `Oracle Corporation` | Manual download — see Step 2a below |
| **After** (target) | Eclipse Temurin 17 (Adoptium OpenJDK) | `Eclipse Adoptium` | `brew install --cask temurin@17` |

> **Why Temurin 17, not Red Hat OpenJDK 17?**
> Red Hat's build of OpenJDK targets RHEL/Fedora Linux (x86_64 and Linux arm64). Red Hat does not publish a native macOS arm64 binary. Eclipse Temurin 17 is an equivalent upstream OpenJDK 17 build from the Eclipse Adoptium project (the successor to AdoptOpenJDK), built from the same source baseline. The demo narrative is updated to reflect this accurately.

## Original configuration
| Item | Value |
|---|---|
| Java target | 17 (`<java.version>17</java.version>` in `pom.xml`, applied via `maven.compiler.release`) |
| Build tool | Maven 3.10.0 (installed via `brew install maven`) |
| Test framework | JUnit Jupiter 5.10.2 |
| Plugins | maven-compiler 3.12.1, surefire 3.2.5, jar 3.3.0 |
| Dependencies | JUnit only (test scope) |
| Runtime dependencies | none |

## Project structure
```
pom.xml
README.md
DEMO_GUIDE.md
demo/index.html              side-by-side dashboard (open in a browser)
demo/results.js              YOUR hand-edited results (reset clears it)
demo/results.template.js     blank results; reset copies this over results.js
scripts/reset-demo.sh        reset (macOS/Linux)
scripts/reset-demo.ps1       reset (Windows PowerShell)
scripts/run-oracle17.sh      build+run with Oracle JDK 17 (auto-locates, fails clearly if missing)
scripts/run-temurin17.sh     build+run with Eclipse Temurin 17 (auto-locates, fails clearly if missing)
src/main/java/com/amgen/demo/sample/{DemoApp,SampleService,LabSample,SampleStatus}.java
src/test/java/com/amgen/demo/sample/SampleServiceTest.java
```

## How the baseline is saved
The original working project is the Git commit `b653fec`, protected by the annotated tag **`demo-baseline`**.

- Reset restores `pom.xml` and `src/` from that tag, resets `demo/results.js` from its template, and deletes `target/`.
- Reset never touches `.git`, `README.md`, `DEMO_GUIDE.md`, `DEMO_SCRIPT.md`, `demo/index.html`, `scripts/`, or anything outside this folder.
- Reset never commits, never runs Maven or Bob, and never starts a migration.
- If files differ from the baseline, reset lists them and requires you to type `reset` before overwriting anything.
- Because the tag does not move when you commit during a run, every run starts from the same baseline. To inspect it: `git show demo-baseline --stat`.
- To change the baseline deliberately (not normally needed): `git tag -f -a demo-baseline <commit> -m "..."`.

## Presentation checklist

### 2a. Install prerequisites (one-time; skip if already done)

**Maven** (already installed if you ran this setup guide):
```bash
brew install maven
mvn -version   # expect: Apache Maven 3.10.x, Java version: 17.x or 21.x
```

**Eclipse Temurin 17** (the OpenJDK 17 target runtime):
```bash
brew install --cask temurin@17
# Will prompt for sudo password once (pkg installer). No account needed.
```

**Oracle JDK 17** (the baseline runtime — manual download required):
1. Go to: https://www.oracle.com/java/technologies/downloads/archive/
2. Click **Java 17**, then **macOS**, then download the **ARM64 Compressed Archive** (`jdk-17.0.x_macos-aarch64_bin.tar.gz`) or the **ARM64 Installer** (`.dmg`)
3. Accept the Oracle No-Fee Terms and Conditions license (no account required)
4. If you downloaded the `.tar.gz`, extract it: `mkdir -p ~/Library/Java/JavaVirtualMachines && tar -xzf jdk-17.0.x_macos-aarch64_bin.tar.gz -C ~/Library/Java/JavaVirtualMachines/`
5. Verify: `/usr/libexec/java_home -V` should now list an Oracle entry for 17.

After installation, verify both JDKs are visible:
```bash
/usr/libexec/java_home -V
# Expected output includes:
#   17.0.x (arm64) "Oracle Corporation" - "Java SE 17.0.x"
#   17.0.20.1 (arm64) "Eclipse Adoptium" - "OpenJDK 17.0.20.1"
```

### 1. Reset the project
```bash
./scripts/reset-demo.sh          # macOS/Linux
pwsh ./scripts/reset-demo.ps1    # Windows (PowerShell 7; or powershell.exe -File .\scripts\reset-demo.ps1)
```
It lists anything it will overwrite and asks you to type `reset`.

### 2. Verify the Oracle JDK baseline and run tests
```bash
./scripts/run-oracle17.sh
```
This script auto-locates Oracle JDK 17, sets `JAVA_HOME` for this run only, builds, tests, and runs the app. Output includes the full Java vendor/version/home info.

Alternatively, set manually and use Maven directly:
```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 17 --vendor Oracle)
export PATH="$JAVA_HOME/bin:/opt/homebrew/bin:$PATH"
java -version   # must show Oracle Corporation
mvn -version    # must show vendor: Oracle Corporation
mvn clean verify
java -jar target/java-modernization-demo-1.0.0.jar
```
Capture: vendor/version output, `Tests run: 8, Failures: 0`, and the demo's Java version/vendor/home lines.

### 3. Open the side-by-side dashboard
```bash
open demo/index.html             # macOS
xdg-open demo/index.html         # Linux
start demo\index.html            # Windows
```
Record the baseline now by editing `demo/results.js` (fields are documented in the file), then refresh the browser. Example, only if it is true:
```js
before: { runtimeDetected: "<first line of java -version>",
          build: { status: "passed", detail: "mvn clean verify: BUILD SUCCESS" },
          tests: { status: "passed", detail: "8 run, 0 failures" } },
```
Status values: `not-run`, `pending`, `passed`, `failed`, `info`. The dashboard shows "Passed" only if a `detail` is also filled in.

### 4. Start IBM Bob's Java Modernization workflow
Open this folder in IBM Bob and launch the installed Java Modernization package using its supported entry point. Suggested prompt:
`Assess this project for migration from Oracle JDK 17 to Red Hat build of OpenJDK 17 and report any real compatibility concerns.`
This is separate from the reset script; nothing here is automated.

### 5. Review the assessment and any suggested changes
```bash
git status
git diff
```
Copy what Bob actually reported into `assessment` and `changes` in `demo/results.js`. If Bob reports no concerns or no file changes, record exactly that.

### 6. Switch to Eclipse Temurin 17 and run the target build
```bash
./scripts/run-temurin17.sh
```
This script auto-locates Temurin 17, sets `JAVA_HOME` for this run only, rebuilds, tests, and runs the app. Confirm the `java.vendor` line shows `Eclipse Adoptium`.

Alternatively, set manually:
```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 17 --vendor "Eclipse Adoptium")
export PATH="$JAVA_HOME/bin:/opt/homebrew/bin:$PATH"
java -version      # should show: openjdk version "17.0.x" ... Eclipse Adoptium
mvn -version       # check the runtime: line shows Temurin path
mvn clean verify
java -jar target/java-modernization-demo-1.0.0.jar
```

### 7. Run the build and tests again (covered by step 6)
The `run-temurin17.sh` script in step 6 runs `mvn clean verify` and the demo app in sequence.
To run only the tests separately:
```bash
# (with JAVA_HOME already set to Temurin 17)
mvn clean verify
java -jar target/java-modernization-demo-1.0.0.jar
```

### 8. Update the dashboard with actual results
Edit the `after` block, plus `assessment`, `changes.files` and `updated`, in `demo/results.js`, then refresh the browser. Record only what you observed.

### 9. Reset for the next presentation
```bash
./scripts/reset-demo.sh
```
If Bob committed anything, the reset still restores `pom.xml` and `src/` to the baseline in the working tree. The extra commits stay in Git history; leave them or remove them yourself, as the script never rewrites history.

## Files to show during the presentation
1. `demo/index.html` (dashboard)
2. `demo/results.js`: the hand-edited results (including optional `vendor`, `version`, `outcome.summary` and per-file `reason`)
3. Bob's assessment and any `git diff` it produces

Code is not walked through during the presentation; the focus is assessment, Bob's assistance and verified results.

## Evidence to capture before migration
- `java -version` and `mvn -version` output (vendor, version, `java.home`)
- `mvn clean verify` result: 8 tests, 0 failures
- Demo output from `java -jar ...`
- Class file level: `javap -v -cp target/classes com.amgen.demo.sample.DemoApp | grep "major version"` (expect 61)
- `git status` and the current commit hash

After migration, repeat the same commands and compare. The vendor and `java.home` lines are expected to change. Source changes are not necessarily expected: this app uses only standard Java APIs, so a migration may legitimately need none. Report what Bob actually finds.
