# java-modernization-demo

A small, fictional laboratory sample tracker used to demonstrate a real Java runtime migration — from **Oracle JDK 17** to **Red Hat build of OpenJDK 17** — with the help of IBM Bob's Java Modernization workflow.

All sample data is synthetic (IDs like `SMP-1001`). The goal is a clean, repeatable evidence base: build passes, 8 tests pass, the app runs and prints its vendor/version/home, and all of that is reproducible on two distinct JDK distributions so the before-and-after comparison is real.

---

## What the application does

| Feature | Details |
|---|---|
| Create a sample | Validates ID format (`SMP-NNNN`), non-blank type, no duplicate; starts as `RECEIVED` |
| Retrieve a sample | Looks up by ID; throws `IllegalArgumentException` on unknown ID |
| Update status | Advances through `RECEIVED → IN_PROGRESS → COMPLETED`; rejects null |
| Invalid input | Returns clear error messages for every rejection case |
| Demo output | Prints `java.version`, `java.vendor`, `java.home` so the active JDK is visible |

No database, no network, no framework, no Docker. Plain Java 17 + Maven + JUnit 5.

---

## The demo story

```
Oracle JDK 17  ──→  IBM Bob (Assess → Recommend → Assist → Validate)  ──→  Red Hat OpenJDK 17
  macOS                         Java Modernization Workflow                  RHEL 9.6 on IBM Cloud
```

| Stage | What happens |
|---|---|
| **Baseline** | Run on Oracle JDK 17 on macOS. 8 tests pass, app prints Oracle vendor string. |
| **Assess** | IBM Bob's Java Modernization workflow scans the project. Reports any Oracle-specific concerns. |
| **Modernize** | Apply the smallest defensible set of changes (possibly none — standard APIs need no changes). |
| **Validate** | Run `mvn clean verify` and the app on the RHEL 9.6 VM with Red Hat OpenJDK 17. |
| **Dashboard** | Record all real results in `demo/results.js`. Open `demo/index.html` to display them. |

---

## Prerequisites

### macOS (before — Oracle JDK 17 baseline)

| Tool | Required version | How to install |
|---|---|---|
| Oracle JDK 17 | 17.x (arm64) | Download from [oracle.com/java/technologies/downloads/archive](https://www.oracle.com/java/technologies/downloads/archive/) → Java 17 → macOS → ARM64. No account required; accept the Oracle No-Fee license. |
| Maven | 3.9+ | `brew install maven` |

> **Note on macOS arm64:** Red Hat does not publish a native macOS arm64 build of OpenJDK. The migration target for this demo is the RHEL 9.6 virtual machine, where Red Hat OpenJDK 17 is already installed. On macOS you establish the Oracle baseline and run IBM Bob. The RHEL VM provides the target validation.

After installing Oracle JDK 17, verify it is visible:

```bash
/usr/libexec/java_home -V
# Must list an Oracle 17 entry, e.g.:
#   17.0.x (arm64) "Oracle Corporation" - "Java SE 17.0.x" /Library/Java/JavaVirtualMachines/jdk-17.x.jdk/Contents/Home
```

### RHEL 9.6 VM (after — Red Hat OpenJDK 17 target)

The target environment is an IBM Cloud VPC virtual machine running RHEL 9.6 with Red Hat OpenJDK 17 already installed. The application source was previously copied to `~/java-modernization-demo/`.

To install prerequisites on a fresh RHEL 9.6 VM:

```bash
sudo dnf install java-17-openjdk-devel maven
java -version   # must show Red Hat, Inc. vendor
mvn -version
```

To copy the project source from macOS to the VM (requires the SSH key `ssh_private_key.pem`):

```bash
# From macOS, in the project root:
scp -i ssh_private_key.pem -r . root@<VM_IP>:~/java-modernization-demo/
```

---

## Running the demo

### Step 1 — Oracle JDK 17 baseline (macOS)

```bash
./scripts/run-oracle17.sh
```

This script locates Oracle JDK 17, sets `JAVA_HOME` for this shell only, prints `java -version`, runs `mvn clean verify`, and runs the demo app. Expected output:

```
=== Java runtime ===
java version "17.0.x" ... LTS
Java(TM) SE Runtime Environment ...
java.vendor: Oracle Corporation

Tests run: 8, Failures: 0, Errors: 0, Skipped: 0
BUILD SUCCESS

Java vendor  : Oracle Corporation
Demo complete.
```

To capture this evidence to `demo/evidence/`:

```bash
./scripts/capture-baseline.sh
```

Sub-commands (no-arg runs the full sequence):

```bash
./scripts/run-oracle17.sh version   # java -version only
./scripts/run-oracle17.sh maven     # mvn -version only
./scripts/run-oracle17.sh app       # run JAR only (requires prior build)
```

### Step 2 — IBM Bob assessment (macOS, in this project folder)

Open this folder in IBM Bob. Start the Java Modernization workflow:

> **Suggested prompt:** "Assess this project for migration from Oracle JDK 17 to Red Hat build of OpenJDK 17 and report any real compatibility concerns."

Record what Bob actually reports in `demo/results.js` (`assessment.status`, `summary`, `findings`). If Bob reports no concerns, record that honestly — it is a valid and expected result for a project that uses only standard Java APIs.

### Step 3 — Apply changes (if any)

Review Bob's suggestions with `git diff`. Apply only what you can justify. If no changes are needed, record `changes: { status: "info", summary: "No changes required", files: [] }`.

### Step 4 — Red Hat OpenJDK 17 validation (RHEL 9.6 VM)

SSH into the VM and run:

```bash
cd ~/java-modernization-demo
./scripts/validate-rhel.sh
```

Or, without the script:

```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH="$JAVA_HOME/bin:$PATH"
java -version           # must show Red Hat, Inc.
mvn -version
mvn clean verify        # expect: Tests run: 8, Failures: 0, BUILD SUCCESS
java -jar target/java-modernization-demo-1.0.0.jar
```

The script produces a summary at the end, including the exact values to paste into `demo/results.js`.

### Step 5 — Update the dashboard

Edit `demo/results.js` with the values you observed. Then open the dashboard:

```bash
open demo/index.html       # macOS
xdg-open demo/index.html   # Linux
```

The dashboard reads from `demo/results.js` only. Nothing is auto-populated. Refresh the browser after each edit.

---

## Direct Maven commands (with JAVA_HOME already set)

```bash
mvn clean verify                              # build + test
mvn test                                      # test only
mvn clean package -DskipTests                 # build without tests
java -jar target/java-modernization-demo-1.0.0.jar   # run app
```

Verify class file level (should be 61 = Java 17):

```bash
javap -v -cp target/classes com.amgen.demo.sample.DemoApp | grep "major version"
# Expected: major version 61
```

---

## Project layout

```
pom.xml                          build configuration; Java version set in <java.version>
README.md
DEMO_GUIDE.md                    presenter setup checklist and per-step instructions
DEMO_SCRIPT.md                   timed run-of-show script with expected outputs and Q&A

src/main/java/com/amgen/demo/sample/
  DemoApp.java                   entry point; prints java.version / java.vendor / java.home
  SampleService.java             all business logic and validation
  LabSample.java                 model (ID, type, status)
  SampleStatus.java              enum: RECEIVED, IN_PROGRESS, COMPLETED, REJECTED

src/test/java/com/amgen/demo/sample/
  SampleServiceTest.java         8 JUnit 5 tests covering create, retrieve, update, and all error paths

demo/
  index.html                     5-section dashboard (open in a browser; no server needed)
  results.js                     hand-edited results — fill in during the demo; reset clears it
  results.template.js            blank template; reset copies this over results.js
  evidence/
    README.txt                   instructions for the evidence directory
    after-java-version.txt       placeholder: RHEL VM java -version output (previously reported)
    after-build.txt              placeholder: RHEL VM mvn clean verify output (previously reported)
    after-app.txt                placeholder: RHEL VM demo app output (previously reported)

scripts/
  run-oracle17.sh                build + test + run on Oracle JDK 17 (macOS, auto-locates JDK)
  run-temurin17.sh               build + test + run on Eclipse Temurin 17 (macOS, alternative)
  capture-baseline.sh            capture Oracle JDK 17 evidence to demo/evidence/
  validate-rhel.sh               validate on Red Hat OpenJDK 17 (RHEL Linux VM)
  reset-demo.sh                  restore pom.xml + src/ from demo-baseline tag; clear results.js
  reset-demo.ps1                 same reset for Windows PowerShell
```

---

## Dashboard

Open `demo/index.html` in any browser. Five sections:

| Section | Content |
|---|---|
| **A — Journey** | Horizontal flow: Oracle JDK 17 → IBM Bob → Red Hat OpenJDK 17 |
| **B — Before/After** | Side-by-side: vendor, version, build, tests, app startup |
| **C — What changed** | Assessment findings, change list (or "no changes required") |
| **D — Impact** | Compatibility, developer effort, validation, remaining risk |
| **E — Evidence** | Compact audit strip: every recorded value and timestamp |

The banner at the top turns green only when both target build and tests are recorded as Passed on a Red Hat runtime.

---

## Reset

```bash
./scripts/reset-demo.sh
```

Lists any files that differ from the `demo-baseline` Git tag and asks you to type `reset`. After reset:

- `pom.xml` and `src/` are restored from the baseline tag
- `demo/results.js` is blanked (copied from `results.template.js`)
- `target/` is deleted
- Everything else — scripts, docs, evidence files, Git history — is untouched

---

## Build configuration

| Setting | Value |
|---|---|
| Java target | 17 (via `<maven.compiler.release>17</maven.compiler.release>`) |
| Compiler plugin | `maven-compiler-plugin` 3.12.1 |
| Test runner | `maven-surefire-plugin` 3.2.5 |
| Packaging | `maven-jar-plugin` 3.3.0 (manifest sets `mainClass`) |
| Test framework | `junit-jupiter` 5.10.2 |
| Runtime dependencies | none |

---

## Related documentation

- [`DEMO_GUIDE.md`](DEMO_GUIDE.md) — full presenter checklist, install steps, and per-step instructions
- [`DEMO_SCRIPT.md`](DEMO_SCRIPT.md) — timed run-of-show script with expected outputs, Q&A, and troubleshooting
- [`demo/evidence/README.txt`](demo/evidence/README.txt) — how to populate and use evidence files
