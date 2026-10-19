# java-modernization-demo

A small, fictional laboratory sample tracker used to demonstrate a real Java runtime migration — from **Oracle JDK 17** to **Eclipse Temurin 17 (OpenJDK)** — with the help of IBM Bob's Java Modernization workflow. All data is synthetic (sample IDs like `SMP-1001`).

The goal is not a complex application. It is a clean, repeatable evidence base: build passes, 8 tests pass, the app runs and prints its vendor/version/home, and all of that is reproducible on two distinct JDK distributions so the before-and-after comparison is real.

---

## What the application does

| Feature | Details |
|---|---|
| Create a sample | Validates ID format (`SMP-NNNN`), non-blank type, no duplicate; starts as `RECEIVED` |
| Retrieve a sample | Looks up by ID; throws on unknown ID |
| Update status | Advances through `RECEIVED → IN_PROGRESS → COMPLETED`; rejects null |
| Invalid input | Returns clear `IllegalArgumentException` messages for every rejection case |
| Demo output | Prints `java.version`, `java.vendor`, `java.home` so the active JDK is visible |

No database, no network, no framework, no Docker. Plain Java 17 + Maven + JUnit 5.

---

## Prerequisites

| Tool | Required version | How to install |
|---|---|---|
| Oracle JDK 17 | 17.x (arm64) | Download from [oracle.com/java/technologies/downloads/archive](https://www.oracle.com/java/technologies/downloads/archive/) → Java 17 → macOS → ARM64 tarball. No account required; accept the Oracle No-Fee license. |
| Eclipse Temurin 17 | 17.x (arm64) | `brew install --cask temurin@17` |
| Maven | 3.9+ | `brew install maven` |

> **Platform note:** this project is set up for **macOS arm64** (Apple Silicon). Red Hat does not publish a native macOS arm64 OpenJDK build. Eclipse Temurin 17, from the Adoptium project, is an equivalent upstream OpenJDK 17 build and is used as the migration target.

After installing both JDKs, verify they are both visible:

```bash
/usr/libexec/java_home -V
# Expected output includes:
#   17.0.x (arm64) "Oracle Corporation" - "Java SE 17.0.x"   /Users/.../jdk-17.0.x.jdk/Contents/Home
#   17.0.x (arm64) "Eclipse Adoptium"  - "OpenJDK 17.0.x"   /Users/.../temurin-17-user.jdk/Contents/Home
```

---

## Running the demo — two runtimes

Two wrapper scripts handle JDK selection, Maven invocation, and the demo app run. Neither script changes your system's default `JAVA_HOME`.

### Oracle JDK 17 (the "before" baseline)

```bash
./scripts/run-oracle17.sh
```

What it does: locates Oracle JDK 17 by reading the `release` file (`IMPLEMENTOR="Oracle Corporation"`), exports `JAVA_HOME` for this shell only, prints `java -version` and `mvn -version`, runs `mvn clean verify`, then runs the demo JAR.

```bash
# Check runtime only (no build):
./scripts/run-oracle17.sh version

# Check Maven version only:
./scripts/run-oracle17.sh maven

# Run the JAR only (requires a prior build):
./scripts/run-oracle17.sh app
```

Expected output includes:
```
java version "17.0.x" ... LTS
Java(TM) SE Runtime Environment ...
java.vendor: Oracle Corporation

Tests run: 8, Failures: 0, Errors: 0, Skipped: 0
BUILD SUCCESS

Java vendor  : Oracle Corporation
Demo complete.
```

### Eclipse Temurin 17 (the "after" target)

```bash
./scripts/run-temurin17.sh
```

Same sub-commands (`version`, `maven`, `app`) as above. Locates Temurin 17 by `IMPLEMENTOR="Eclipse Adoptium"` in the `release` file.

Expected output includes:
```
openjdk version "17.0.x" ...
OpenJDK Runtime Environment Temurin-17.0.x ...
java.vendor: Eclipse Adoptium

Tests run: 8, Failures: 0, Errors: 0, Skipped: 0
BUILD SUCCESS

Java vendor  : Eclipse Adoptium
Demo complete.
```

### Direct Maven commands (with JAVA_HOME already set)

```bash
# Build and run all tests
mvn clean verify

# Run tests only (skip compile if nothing changed)
mvn test

# Package only (no tests)
mvn clean package

# Run the demo app
java -jar target/java-modernization-demo-1.0.0.jar
```

---

## Project layout

```
pom.xml                          build configuration; Java version set in <java.version>
README.md
DEMO_GUIDE.md                    step-by-step presenter setup and checklist
DEMO_SCRIPT.md                   run-of-show script with timing, expected output, and Q&A

src/main/java/com/amgen/demo/sample/
  DemoApp.java                   entry point; prints java.version / java.vendor / java.home
  SampleService.java             all business logic and validation
  LabSample.java                 model (ID, type, status, createdAt)
  SampleStatus.java              enum: RECEIVED, IN_PROGRESS, COMPLETED, REJECTED

src/test/java/com/amgen/demo/sample/
  SampleServiceTest.java         8 JUnit 5 tests covering create, retrieve, update, and all error paths

demo/
  index.html                     side-by-side dashboard (open in a browser; no server needed)
  results.js                     hand-edited results file — fill in during the demo, reset clears it
  results.template.js            blank template; reset copies this over results.js

scripts/
  run-oracle17.sh                build + test + run on Oracle JDK 17
  run-temurin17.sh               build + test + run on Eclipse Temurin 17
  reset-demo.sh                  restore pom.xml and src/ from the demo-baseline tag; clear results.js
  reset-demo.ps1                 same reset for Windows PowerShell
```

---

## Dashboard

Open `demo/index.html` in any browser (no server required):

```bash
open demo/index.html        # macOS
```

The dashboard shows three columns — Oracle JDK 17, IBM Bob assessment, Eclipse Temurin 17 — and reads from `demo/results.js`. Fill that file in by hand as each step completes during the demo. Nothing is pre-populated; every badge is earned by a real run.

---

## Reset

```bash
./scripts/reset-demo.sh
```

Lists any files that differ from the `demo-baseline` Git tag and asks you to type `reset` before overwriting anything. After reset:

- `pom.xml` and `src/` are restored from the baseline tag
- `demo/results.js` is blanked (copied from `results.template.js`)
- `target/` is deleted
- Everything else — `.git`, scripts, docs, dashboard — is untouched

The two JDKs and Maven are not affected by reset.

---

## Build configuration

| Setting | Value |
|---|---|
| Java target | 17 (set via `<maven.compiler.release>17</maven.compiler.release>`) |
| Compiler plugin | `maven-compiler-plugin` 3.12.1 |
| Test runner | `maven-surefire-plugin` 3.2.5 |
| Packaging | `maven-jar-plugin` 3.3.0 (manifest sets `mainClass`) |
| Test framework | `junit-jupiter` 5.10.2 |
| Runtime deps | none |

The class files produced are major version 61 (Java 17), regardless of which JDK 17 build compiles them. Verify with:

```bash
javap -v -cp target/classes com.amgen.demo.sample.DemoApp | grep "major version"
# Expected: major version 61
```

---

## Related documentation

- [`DEMO_GUIDE.md`](DEMO_GUIDE.md) — full presenter checklist, install steps, and per-step instructions
- [`DEMO_SCRIPT.md`](DEMO_SCRIPT.md) — timed run-of-show script with expected outputs, Q&A table, and troubleshooting
