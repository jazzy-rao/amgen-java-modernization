# Demo Script: Java Modernization with IBM Bob (about 15 minutes)

Scenario: a small, fictional lab sample tracker (synthetic IDs like `SMP-1001`) moves from **Oracle JDK 17** to **Red Hat build of OpenJDK 17**. IBM Bob's Java Modernization workflow assists. The point is the workflow: assess, change only what is needed, then prove it with a real build and tests.

> Honesty rule for the whole demo: say only what you observe. This app uses only standard Java APIs, so Bob may legitimately report **no required code changes**. That is a good outcome, not a failed demo. Nothing below predicts what Bob will say; sections marked **Bob-dependent** describe how to handle either result.

Reference: `DEMO_GUIDE.md` has the background and reset details. This file is the run-of-show.

---

## Timing at a glance

| # | Section | Time |
|---|---|---|
| 0 | Pre-demo setup (before the audience arrives) | not timed |
| 1 | Introduce the scenario | 1 min |
| 2 | Walk the code | 2 min |
| 3 | Baseline: Oracle JDK 17 build, tests, run | 2 min |
| 4 | Dashboard and recording the baseline | 1 min |
| 5 | Bob: assess the project | 3 min |
| 6 | Bob: review suggested changes | 2 min |
| 7 | Switch to Red Hat OpenJDK 17, rebuild, retest | 2 min |
| 8 | Dashboard: compare before and after | 1 min |
| 9 | Wrap up and reset | 1 min |

---

## 0. Pre-demo setup (do this 30+ minutes before)

**Prerequisites**
- Oracle JDK 17 installed. The prep machine only had Eclipse Temurin 21, so this is manual.
- Red Hat build of OpenJDK 17 installed.
- Maven 3.9+ on `PATH` (on the prep machine: `export PATH=~/.m2/wrapper/dists/apache-maven-3.9.9/3477a4f1/bin:$PATH`).
- IBM Bob open on this folder with the Java Modernization package installed.
- Dependencies cached once: run `mvn clean verify` with network access once, then `-o` works offline.

**Check and reset**
```bash
cd "/Users/jazzyrao/Downloads/Amgen/amgen java mod"
git status                      # expect: nothing to commit, working tree clean
./scripts/reset-demo.sh         # expect: "Project already matches the baseline" or a list to confirm with "reset"
```

**Set Java to Oracle JDK 17** (macOS example; adjust the path to your install):
```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 17)    # use the Oracle entry if several 17s are installed
export PATH="$JAVA_HOME/bin:$PATH"
java -version
```
Expected: a first line like `java version "17.0.x" ...` and a second line mentioning `Java(TM) SE Runtime Environment`. If it does not say Oracle, stop: the "before" side would not be an Oracle baseline. Say so honestly, or fix `JAVA_HOME`.

**Windows**: use `set JAVA_HOME=...` and `set PATH=%JAVA_HOME%\bin;%PATH%`, and `pwsh ./scripts/reset-demo.ps1` (untested).

**Have ready in tabs/windows**: a terminal in the project folder, an editor with `pom.xml`, a browser tab on `demo/index.html`, and Bob.

---

## 1. Introduce the scenario (1 min)

**Say:** "Many teams run on Oracle JDK and want to move to a supported open build such as Red Hat's OpenJDK, often for licensing and support reasons. The worry is what breaks. I'll show how Bob helps find that out, change only what's needed, and prove it with a build and tests."

**Show:** `demo/index.html` in the browser.

**Expect:** three columns (Oracle JDK 17, IBM Bob, Red Hat OpenJDK 17). Everything reads **Not yet run**, and PLANNED / FINDING / CHANGE / VERIFIED labels sit on each section.

**Say:** "This board is empty on purpose. I fill it in by hand with what actually happens, and nothing shows as Passed unless a real run supports it."

---

## 2. Walk the code (2 min)

Open these in order:

1. **`pom.xml`**
   - Point to `<java.version>17</java.version>` in the properties block.
   - Point out that there are no vendor-specific settings, and that the only dependency is JUnit in test scope.
   - **Say:** "Java version lives in one place. No Oracle-specific plugins or flags."
2. **`DemoApp.java`**
   - Show that it prints `java.version`, `java.vendor` and `java.home`.
   - **Say:** "This gives us visible proof of which runtime is executing."
3. **`SampleService.java`**
   - Create, get, update status, validation with clear messages.
   - **Say:** "Plain Java, standard APIs only."
4. **`SampleServiceTest.java`**
   - **Say:** "8 tests. This is the safety net that tells us the migration is sound."

---

## 3. Baseline on Oracle JDK 17 (2 min)

```bash
java -version
mvn -version
mvn clean verify
java -jar target/java-modernization-demo-1.0.0.jar
```

**Expect `java -version`:** Oracle JDK 17 vendor/runtime lines (your values will differ from the prep machine).

**Expect `mvn -version`:** the Maven line, plus `Java version: 17.x, vendor: Oracle Corporation, runtime: <your Oracle JDK path>`.

**Expect `mvn clean verify`** (verified on the prep machine; only the Java vendor/version differ):
```
[INFO] Running com.amgen.demo.sample.SampleServiceTest
[INFO] Tests run: 8, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

**Expect the demo run.** The `Java ...` lines show your JDK; the rest is deterministic (verified on the prep machine):
```
==============================================
 Lab Sample Tracker - Java Modernization Demo
==============================================
Java version : <your version>
Java vendor  : <your vendor, expected Oracle Corporation>
Java home    : <your JAVA_HOME>

[1] Create samples
    SMP-1001 | Blood Plasma | RECEIVED
    SMP-1002 | Cell Culture | RECEIVED
[2] Retrieve sample SMP-1001
    SMP-1001 | Blood Plasma | RECEIVED
[3] Update status of SMP-1001
    SMP-1001 | Blood Plasma | IN_PROGRESS
    SMP-1001 | Blood Plasma | COMPLETED
[4] Invalid input handling
    Rejected: Invalid sample ID 'BAD-ID': expected format SMP-1234
    Rejected: Sample type must not be blank
    Rejected: Sample not found: SMP-9999

Demo complete.
```

**Optional evidence** (class file level, expect `major version: 61`):
```bash
javap -v -cp target/classes com.amgen.demo.sample.DemoApp | grep "major version"
```

**Say:** "Green baseline on Oracle JDK 17: 8 tests pass and the app runs. Now any difference later is attributable to the migration."

**If it fails:** do not continue. See Troubleshooting.

---

## 4. Record the baseline on the dashboard (1 min)

Edit `demo/results.js`, only with values you just saw:
```js
updated: "<date time>",
before: {
  runtimeDetected: "<first line of java -version>",
  build: { status: "passed", detail: "mvn clean verify: BUILD SUCCESS" },
  tests: { status: "passed", detail: "8 run, 0 failures" }
},
```
Refresh the browser.

**Expect:** the left column's Build and Tests badges turn green **Passed** with your detail text, and "Detected" shows your runtime. The Assist and After columns are still **Not yet run**.

(Tip: save this edit before the demo as a snippet so typing does not eat time. Only apply it after the baseline really ran.)

---

## 5. Bob: assess the project (3 min) — Bob-dependent

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

Record Bob's actual report in `demo/results.js` (`assessment.status`, `summary`, `findings`).

**Expect on the dashboard after refresh:** the Assessment row in the middle column shows your recorded status and summary instead of "Not yet run".

---

## 6. Bob: review suggested changes (2 min) — Bob-dependent

Review before accepting anything:
```bash
git status
git diff
```

**Expect (one of two outcomes):**
- **No changes proposed:** `git status` still reports a clean tree. **Say:** "No code changes needed. The value here was the assessment and the evidence."
- **Changes proposed or applied:** `git diff` shows exactly which files. Walk through each change and what it is for. Only accept what you can justify.

Record in `demo/results.js` under `changes` (`status`, `summary`, `files: [{ path, note }]`). Use `files: []` if none.

---

## 7. Switch to Red Hat OpenJDK 17, rebuild and retest (2 min)

Use the step the workflow gives you, or switch manually:
```bash
export JAVA_HOME=<path to Red Hat OpenJDK 17>      # macOS: /usr/libexec/java_home -V lists installs
export PATH="$JAVA_HOME/bin:$PATH"
java -version
mvn -version
mvn clean verify
java -jar target/java-modernization-demo-1.0.0.jar
```

**Expect `java -version`:** an `openjdk version "17.0.x"` line, with a Red Hat build in the runtime line (for example `OpenJDK Runtime Environment (Red_Hat-...)`; confirm the exact text on your install).

**Expect `mvn clean verify`:** if the migration is clean, the same shape as the baseline: `Tests run: 8, Failures: 0, Errors: 0, Skipped: 0` and `BUILD SUCCESS`. Report whatever you actually get.

**Expect the demo run:** identical to the baseline output except the `Java version`, `Java vendor` (expected to read `Red Hat, Inc.`; confirm on your install) and `Java home` lines.

**Say:** "Same code, same tests, different vendor build. The only differences are the runtime lines."

**If the build or tests fail:** that is a real finding. Show the error, say that it is a genuine result, and record it as Failed. See Troubleshooting.

---

## 8. Dashboard: compare before and after (1 min)

Edit `demo/results.js` using only observed values:
```js
after: {
  runtimeDetected: "<first line of java -version on Red Hat JDK>",
  build: { status: "passed", detail: "mvn clean verify: BUILD SUCCESS" },
  tests: { status: "passed", detail: "8 run, 0 failures" },
  followUps: []        // e.g. ["Update CI base image"] only if real
}
```
Set `failed` and detail text instead if something failed. Refresh the browser.

**Expect:** the right column shows your runtime, Build and Tests badges. The "Latest validation summary" and "Files changed" sections at the bottom reflect your entries. The note under the columns reminds the audience that code changes are not necessarily required.

**Say:** "Left: baseline evidence on Oracle JDK 17. Middle: what Bob found and changed. Right: proof on Red Hat OpenJDK 17. Every badge here came from a real run."

---

## 9. Wrap up and reset (1 min)

**Say (suggested):**
- "Bob gave a structured assessment and kept the change set minimal."
- "The tests gave objective proof, not a guess."
- "For this app the migration needed [no / these] code changes; that's what the evidence showed."

**Reset for the next run:**
```bash
./scripts/reset-demo.sh
```
**Expect:** it lists files that differ from the `demo-baseline` tag and asks you to type `reset`. Typing anything else cancels with no changes. After `reset`: `pom.xml` and `src/` are restored, `demo/results.js` is blank again, and `target/` is removed.

Note: commits Bob made stay in Git history. The script never rewrites history and never commits.

---

## Likely audience questions

| Question | Honest answer |
|---|---|
| Will my code need changes? | Not necessarily. Standard APIs behave the same across 17 builds. Real issues tend to be in vendor-specific APIs, JVM flags, build/CI config or container images. Bob's assessment tells you for your code. |
| Was the baseline really Oracle? | Only if the `java -version` and `Java vendor` output on screen said so. The prep machine only had Temurin 21. |
| Did this prove production readiness? | No. It shows this small app builds and passes 8 tests. Production needs your full test suite, performance checks and support-contract review. |
| Is the dashboard automatic? | No. It displays hand-entered results from `demo/results.js`. |

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `mvn: command not found` | Maven not on `PATH` | `export PATH=~/.m2/wrapper/dists/apache-maven-3.9.9/3477a4f1/bin:$PATH` |
| `java -version` shows the wrong vendor | `JAVA_HOME`/`PATH` not set | Re-export both (section 0 or 7) in the same terminal |
| Maven cannot download artifacts | No network and cache empty | Run once online; use `mvn -o clean verify` afterwards |
| `release version 17 not supported` | JDK older than 17 | Use a 17+ JDK |
| Dashboard looks blank/unchanged | Browser cache or syntax error in `results.js` | Hard refresh; check for missing commas or quotes |
| Dashboard shows "Pending verification" for a passed run | `detail` is empty | Fill in the `detail` text |
| Reset reports differences you did not expect | Local edits or Bob changes | Read the list before typing `reset` |
| Commit shows a "Block Secrets" notice | IBM Vault Radar scan on this machine | Informational; the commit still succeeds |
| Build fails after migration | A real finding | Show the error, record **Failed** on the dashboard, and discuss it. Do not hide it. |

---

## Presenter checklist (print or keep beside you)

- [ ] Oracle JDK 17 and Red Hat OpenJDK 17 installed; both `JAVA_HOME` paths known
- [ ] `git status` clean and `./scripts/reset-demo.sh` run
- [ ] `java -version` shows Oracle before starting
- [ ] Baseline: 8 tests, 0 failures, `BUILD SUCCESS`
- [ ] Dashboard updated only with observed results
- [ ] Bob's actual report and diff reviewed before accepting
- [ ] Red Hat runtime confirmed with `java -version` before the second build
- [ ] After-run recorded; reset run at the end
