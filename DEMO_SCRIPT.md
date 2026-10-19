# Demo Script: Java Modernization with IBM Bob (about 12 minutes)

Scenario: a small, fictional lab sample tracker (synthetic IDs like `SMP-1001`) moves from **Oracle JDK 17** to **Eclipse Temurin 17 (upstream OpenJDK 17 build, from the Eclipse Adoptium project)**. IBM Bob's Java Modernization workflow assists. The point is the workflow: assess, change only what is needed, then prove it with a real build and tests.

> **Runtime note:** This machine runs macOS arm64. Red Hat does not publish a native macOS arm64 OpenJDK build. Eclipse Temurin 17 is an equivalent OpenJDK 17 distribution from Adoptium (the successor to AdoptOpenJDK), built from the same upstream source baseline. The demo is updated to reflect this accurately. The demonstration of moving from a commercial Oracle JDK to a freely-supported OpenJDK distribution remains valid.

> Honesty rule for the whole demo: say only what you observe. This app uses only standard Java APIs, so Bob may legitimately report **no required code changes**. That is a good outcome, not a failed demo. Nothing below predicts what Bob will say; sections marked **Bob-dependent** describe how to handle either result.

Narrative: **assessment** (what Bob finds), **Bob's assistance** (what it changes, and why), **verified results** (real build and test runs). Code is not walked through; Bob's assessment covers it.

Reference: `DEMO_GUIDE.md` has the background and reset details. This file is the run-of-show.

---

## Timing at a glance

| # | Section | Time |
|---|---|---|
| 0 | Pre-demo setup (before the audience arrives) | not timed |
| 1 | Introduce the scenario | 1 min |
| 2 | Baseline: Oracle JDK 17 build, tests, run | 2 min |
| 3 | Record the baseline | 1 min |
| 4 | Bob: assess the project | 3 min |
| 5 | Bob: review changes (if any) | 2 min |
| 6 | Switch to Red Hat OpenJDK 17, rebuild, retest | 2 min |
| 7 | Dashboard: findings, changes, verified outcome | 1 min |
| 8 | Wrap up and reset | within section 7's minute |

---

## 0. Pre-demo setup (do this 30+ minutes before)

**Prerequisites**
- Oracle JDK 17 installed (manual download — see `DEMO_GUIDE.md` § 2a for the exact URL and steps).
- Eclipse Temurin 17 installed: `brew install --cask temurin@17` (one sudo prompt; no account needed).
- Maven 3.10+ installed: `brew install maven` (already done if you followed this guide).
- IBM Bob open on this folder with the Java Modernization package installed.
- Dependencies cached: run `mvn clean verify` with network access once, then `mvn -o clean verify` works offline.

**Check and reset**
```bash
cd "/Users/jazzyrao/Downloads/Amgen/amgen java mod"
git status                      # expect: nothing to commit, working tree clean
./scripts/reset-demo.sh         # expect: "Project already matches the baseline" or a list to confirm with "reset"
```

**Verify both JDKs are visible:**
```bash
/usr/libexec/java_home -V
# Must list an Oracle 17 entry AND an Eclipse Adoptium 17 entry.
# Example:
#   17.0.x (arm64) "Oracle Corporation" - "Java SE 17.0.x" /Library/Java/JavaVirtualMachines/jdk-17.0.x.jdk/Contents/Home
#   17.0.20.1 (arm64) "Eclipse Adoptium" - "OpenJDK 17.0.20.1" /Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
```

**Verify Maven is on PATH:**
```bash
/opt/homebrew/bin/mvn -version   # or just: mvn -version  (if /opt/homebrew/bin is on your PATH)
```

**Have ready in tabs/windows**: a terminal in the project folder, an editor on `demo/results.js`, a browser tab on `demo/index.html`, and Bob.

---

## 1. Introduce the scenario (1 min)

**Say:** "Many teams run on Oracle JDK and want to move to a supported open build such as Red Hat's OpenJDK, often for licensing and support reasons. The worry is what breaks. I'll show how Bob helps find that out, change only what's needed, and prove it with a build and tests."

**Show:** `demo/index.html` in the browser.

**Expect:** three columns (Oracle JDK 17, IBM Bob, Red Hat OpenJDK 17). Everything reads **Not yet run**, and PLANNED / FINDING / CHANGE / VERIFIED labels sit on each section.

**Say:** "This board is empty on purpose. I fill it in by hand with what actually happens, and nothing shows as Passed unless a real run supports it."

---

## 2. Baseline on Oracle JDK 17 (2 min)

```bash
./scripts/run-oracle17.sh
```
This single command locates Oracle JDK 17, prints its `java -version`, runs `mvn clean verify`, and runs the demo app.

Alternatively, manually:
```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 17 --vendor Oracle)
export PATH="$JAVA_HOME/bin:/opt/homebrew/bin:$PATH"
java -version
mvn -version
mvn clean verify
java -jar target/java-modernization-demo-1.0.0.jar
```

**Expect `java -version`:** a first line like `java version "17.0.x" 20xx-xx-xx LTS` and a second line `Java(TM) SE Runtime Environment` — the Oracle lines. If you see `Eclipse Adoptium` or `Temurin`, `JAVA_HOME` is wrong; fix it before continuing.

**Expect `mvn -version`:** the Maven line, plus `Java version: 17.x, vendor: Oracle Corporation, runtime: <your Oracle JDK path>`.

**Expect `mvn clean verify`:**
```
[INFO] Running com.amgen.demo.sample.SampleServiceTest
[INFO] Tests run: 8, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

**Expect the demo run:** the `Java version`, `Java vendor` and `Java home` lines show your Oracle JDK; the rest of the output is deterministic sample processing and ends with `Demo complete.`

**Say:** "Green baseline on Oracle JDK 17: 8 tests pass and the app runs. Now any difference later is attributable to the migration."

**If it fails:** do not continue. See Troubleshooting.

---

## 3. Record the baseline on the dashboard (1 min)

Edit `demo/results.js`, only with values you just saw:
```js
updated: "<date time>",
before: {
  vendor: "<observed java.vendor>",
  version: "<observed java.version>",
  runtimeDetected: "<first line of java -version>",
  build: { status: "passed", detail: "mvn clean verify: BUILD SUCCESS" },
  tests: { status: "passed", detail: "8 run, 0 failures" }
},
```
Refresh the browser.

**Expect:** the left column's Build and Tests badges turn green **Passed** with your detail text, and the runtime shows what you recorded. The top banner still reads that the outcome is not yet recorded, because nothing has been assessed or validated on the target.

(Tip: save this edit before the demo as a snippet so typing does not eat time. Only apply it after the baseline really ran.)

---

## 4. Bob: assess the project (3 min) — Bob-dependent

In Bob, with this folder open, start the Java Modernization workflow using its supported entry point. Suggested prompt:

> Assess this project for migration from Oracle JDK 17 to Red Hat build of OpenJDK 17 and report any real compatibility concerns.

**Say while it runs:** "Bob reads the build configuration, the source and the tests, and looks for vendor-specific dependencies."

**What to expect (examples of the kinds of areas Bob could look at, not predictions):**
- `pom.xml` and compiler/toolchain settings.
- Use of vendor-specific or internal JDK APIs in source.
- JVM flags, launch scripts, CI or container references to Oracle JDK.

**Handle either outcome honestly:**
- **Bob reports no compatibility concerns:** say "This is the expected case for an app using only standard APIs. Moving between 17 builds does not necessarily require code changes." Record it as such.
- **Bob reports items:** read each one aloud, then check it against the code before accepting it. If a finding does not match the code, say so.

Record Bob's actual report in `demo/results.js` (`assessment.status`, `summary`, `findings`). These are **findings**: what Bob reported, not changes made.

**Expect on the dashboard after refresh:** the "Assessment findings" section shows your recorded status, summary and findings, and the banner reads "Assessment recorded: target validation pending".

---

## 5. Bob: review changes, if any (2 min) — Bob-dependent

Review before accepting anything:
```bash
git status
git diff
```

**Expect (one of two outcomes):**
- **No changes proposed:** `git status` still reports a clean tree. **Say:** "No code changes were identified as required. The value here was the assessment and the evidence." Record `status: "info"`, a summary, and `files: []`; the dashboard shows this as a positive result, not an empty section.
- **Changes proposed or applied:** `git diff` shows exactly which files. Walk through each change and what it is for. Only accept what you can justify, and record each file with a `reason`.

Record in `demo/results.js` under `changes` (`status`, `summary`, `files: [{ path, note, reason }]`).

---

## 6. Switch to Eclipse Temurin 17, rebuild and retest (2 min)

```bash
./scripts/run-temurin17.sh
```
This single command locates Temurin 17, prints its `java -version`, runs `mvn clean verify`, and runs the demo app.

Alternatively, manually:
```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 17 --vendor "Eclipse Adoptium")
export PATH="$JAVA_HOME/bin:/opt/homebrew/bin:$PATH"
java -version
mvn -version
mvn clean verify
java -jar target/java-modernization-demo-1.0.0.jar
```

**Expect `java -version`:** `openjdk version "17.0.x"` and a runtime line mentioning `Temurin-17` or `Eclipse Adoptium`.

**Expect `mvn clean verify`:** if the migration is clean, the same shape as the baseline: `Tests run: 8, Failures: 0, Errors: 0, Skipped: 0` and `BUILD SUCCESS`. Report whatever you actually get.

**Say:** "Same code, same tests, different vendor build — now on OpenJDK 17." Confirm the demo run's `Java vendor` line reflects `Eclipse Adoptium`.

**If the build or tests fail:** that is a real finding. Show the error, say that it is a genuine result, and record it as Failed. See Troubleshooting.

---

## 7. Dashboard: findings, changes, verified outcome (1 min)

Edit `demo/results.js` using only observed values:
```js
outcome: { summary: "<one sentence, written only after validation>" },
after: {
  vendor: "<observed java.vendor>",
  version: "<observed java.version>",
  runtimeDetected: "<first line of java -version on Red Hat JDK>",
  build: { status: "passed", detail: "mvn clean verify: BUILD SUCCESS" },
  tests: { status: "passed", detail: "8 run, 0 failures" },
  followUps: []        // e.g. ["Update CI base image"] only if real
}
```
Set `failed` and detail text instead if something failed. Refresh the browser.

**Expect:** the banner at the top turns green ("Validated") only when the target build and tests are both Passed with detail on a Red Hat runtime; red if either failed. Below the columns, three separate sections show **Assessment findings** (what Bob reported), **Source and configuration changes** (what was actually applied, or "no changes required") and **Verified outcomes** (before vs. after vendor, version, Maven build, unit tests). A yellow note appears if a recorded vendor is not Oracle (before) or Red Hat (after).

**Say:** "Findings are what Bob reported. Changes are what was actually applied and why. Verified outcomes are real build and test runs. Each is shown separately."

---

## 8. Wrap up and reset

**Say (suggested):**
- "Bob gave a structured assessment and kept any change set minimal."
- "The tests gave objective proof, not a guess."
- "For this app the migration needed [no / these] code changes; that's what the evidence showed."

**Reset for the next run:**
```bash
./scripts/reset-demo.sh
```
**Expect:** it lists files that differ from the `demo-baseline` tag and asks you to type `reset`. Typing anything else cancels with no changes. After `reset`: `pom.xml` and `src/` are restored, `demo/results.js` is blank again, and `target/` is removed. The dashboard, `DEMO_GUIDE.md`, this script, `scripts/` and Git history are untouched.

Note: commits Bob made stay in Git history. The script never rewrites history and never commits.

---

## Likely audience questions

| Question | Honest answer |
|---|---|
| Will my code need changes? | Not necessarily. Standard APIs behave the same across 17 builds. Real issues tend to be in vendor-specific APIs, JVM flags, build/CI config or container images. Bob's assessment tells you for your code. |
| Was the baseline really Oracle? | Only if the `java -version` and `Java vendor` output on screen said so. The script exits immediately if Oracle JDK 17 is not found. |
| Why Temurin instead of Red Hat OpenJDK? | Red Hat does not publish a native macOS arm64 binary. Temurin is an equivalent upstream build from Adoptium. The licensing-and-support story (moving away from Oracle's commercial JDK) is identical: the target is a freely supported, non-Oracle OpenJDK build. |
| Did this prove production readiness? | No. It shows this small app builds and passes 8 tests. Production needs your full test suite, performance checks and support-contract review. |
| Is the dashboard automatic? | No. It displays hand-entered results from `demo/results.js`. |

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `mvn: command not found` | Maven not on `PATH` | `export PATH=/opt/homebrew/bin:$PATH` (Homebrew installs Maven there) |
| `run-oracle17.sh` exits with "Oracle JDK 17 not found" | Oracle JDK 17 not installed | Follow the download steps in `DEMO_GUIDE.md` § 2a |
| `run-temurin17.sh` exits with "Temurin 17 not found" | Temurin 17 not installed | `brew install --cask temurin@17` (prompts for sudo) |
| `java -version` shows the wrong vendor | `JAVA_HOME`/`PATH` not set correctly in this terminal | Run the appropriate `scripts/run-*.sh` script which sets it automatically |
| Maven cannot download artifacts | No network and cache empty | Run once online; use `mvn -o clean verify` afterwards |
| `release version 17 not supported` | JDK older than 17 | Use a 17+ JDK; the run scripts enforce this |
| Dashboard looks blank/unchanged | Browser cache or syntax error in `results.js` | Hard refresh; check for missing commas or quotes |
| Dashboard shows "Pending verification" for a passed run | `detail` is empty | Fill in the `detail` text |
| Reset reports differences you did not expect | Local edits or Bob changes | Read the list before typing `reset` |
| Commit shows a "Block Secrets" notice | IBM Vault Radar scan on this machine | Informational; the commit still succeeds |
| Build fails after migration | A real finding | Show the error, record **Failed** on the dashboard, and discuss it. Do not hide it. |

---

## Presenter checklist (print or keep beside you)

- [ ] Oracle JDK 17 installed; `/usr/libexec/java_home -V` shows an Oracle 17 entry
- [ ] Eclipse Temurin 17 installed; `/usr/libexec/java_home -V` shows an Adoptium 17 entry
- [ ] `git status` clean and `./scripts/reset-demo.sh` run
- [ ] `./scripts/run-oracle17.sh version` shows Oracle Corporation vendor
- [ ] Baseline (`./scripts/run-oracle17.sh`): 8 tests, 0 failures, `BUILD SUCCESS`
- [ ] Dashboard updated only with observed results (including `vendor` and `version`)
- [ ] Bob's actual report and diff reviewed before accepting
- [ ] `./scripts/run-temurin17.sh version` shows Eclipse Adoptium vendor before the second build
- [ ] After-run recorded; reset run at the end (`./scripts/reset-demo.sh`)
