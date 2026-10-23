# Demo Script — Java Modernization with IBM Bob (10–15 min)

**Scenario:** A fictional lab sample tracker running on Oracle JDK 17 moves to Red Hat build of OpenJDK 17 on RHEL 9.6 (IBM Cloud VM). IBM Bob's Java Modernization workflow guides the assessment and any required changes. The point is the workflow — assess, change only what is needed, prove it works.

**Audience:** Amgen engineering and IT leadership.

**Honesty rule:** Say only what you observe. This application uses only standard Java APIs. Bob may legitimately report no required code changes. That is a good outcome, not a failed demo. Nothing below predicts what Bob will say.

**Target runtime note:** Red Hat does not publish a native macOS arm64 build of OpenJDK. The Oracle JDK 17 baseline runs on your macOS laptop. The Red Hat OpenJDK 17 validation runs on an IBM Cloud VPC VM running RHEL 9.6. Both environments produce real, capturable evidence.

---

## Timing at a glance

| # | Section | Time |
|---|---|---|
| 0 | Pre-demo setup (before audience arrives) | not timed |
| 1 | Introduce the scenario | 1 min |
| 2 | Baseline: Oracle JDK 17 on macOS | 2 min |
| 3 | Record the baseline on the dashboard | 1 min |
| 4 | IBM Bob: assess the project | 3 min |
| 5 | IBM Bob: review any changes | 2 min |
| 6 | Validate on Red Hat OpenJDK 17 (RHEL 9.6 VM) | 3 min |
| 7 | Dashboard: show the verified outcome | 1–2 min |
| 8 | Wrap up + reset | within section 7 |

**Total:** 13–14 minutes with comfortable pace.

---

## 0. Pre-demo setup (do this 30+ minutes before)

**On macOS:**
- Oracle JDK 17 installed (see DEMO_GUIDE.md § 2a for the exact steps)
- Maven installed: `brew install maven`
- IBM Bob open on this folder with the Java Modernization package installed
- Dependencies cached: run `mvn clean verify` once with network; then `mvn -o clean verify` works offline

**Check and reset:**
```bash
cd "/Users/jazzyrao/Downloads/Amgen/amgen java mod"
git status
./scripts/reset-demo.sh
```

> **Note:** `reset-demo.sh` will detect that `demo/results.js` differs from the blank template (it has real captured values in it now) and will ask you to type `reset`. **Do not reset before the demo** — the before-panel values are already filled in and correct. Only run the reset *after* the presentation is finished.
>
> If you genuinely need to start from a blank slate, type `reset` when prompted. Then re-run `./scripts/capture-baseline.sh` to repopulate the Oracle evidence, and copy the before-panel values back into `demo/results.js` before presenting.

**Verify Oracle JDK 17:**
```bash
./scripts/run-oracle17.sh version
# Must show: Java(TM) SE Runtime Environment ... Oracle Corporation
```

**On the RHEL 9.6 VM:**
- Red Hat OpenJDK 17 installed (`sudo dnf install java-17-openjdk-devel`)
- Maven installed (`sudo dnf install maven`)
- Project source present at `~/java-modernization-demo/`
- Run a test validation: `./scripts/validate-rhel.sh` — confirm it completes without errors

If the source is not on the VM yet, copy it:
```bash
# From macOS, in the project root:
scp -i ssh_private_key.pem -r . root@<VM_IP>:~/java-modernization-demo/
```

**Have ready in tabs/windows:**
1. Terminal on macOS (project folder)
2. Terminal via SSH on the RHEL VM
3. Browser tab on `demo/index.html`
4. Text editor on `demo/results.js`
5. IBM Bob (Java Modernization workflow)

---

## 1. Introduce the scenario (1 min)

**Show:** `demo/index.html` in the browser.

The **Before** (left) panel already shows green — `Oracle Corporation / 17.0.20.1 / 8 tests passed`. This is intentional: the Oracle baseline was captured in advance so you are not wasting presentation time running a build the audience has already seen. The **After** (right) panel is blank — those results come from the live RHEL VM run in Section 6.

**Say:** "Many teams run on Oracle JDK — historically because of support agreements, tooling familiarity, or historical defaults. Moving to Red Hat's build of OpenJDK is increasingly common for licensing clarity and to align with Red Hat Enterprise Linux environments. The question teams ask is: what breaks? I'll show how IBM Bob helps answer that systematically, and how we validate the result with a real build and test run on a Red Hat Enterprise Linux 9.6 virtual machine."

**Point out on the dashboard:**
- Section A (Journey): three stages — Oracle JDK 17, IBM Bob, Red Hat OpenJDK 17 on RHEL 9.6
- Section B (Before/After): the left panel shows the captured Oracle baseline; the right panel is empty — it fills in live during Section 6
- Section C (What changed): shows Bob's assessment summary — no concerns found
- Section E (Evidence): the audit strip — the After column shows "Not yet verified" until we earn it

**Say:** "The Oracle baseline is already recorded — I ran it before you arrived so we don't spend your time watching a build scroll. Everything on the right side gets filled in live. Nothing shows as Passed until a real run on the RHEL VM supports it."

---

## 2. Baseline: Oracle JDK 17 (2 min)

```bash
./scripts/run-oracle17.sh
```

This single command locates Oracle JDK 17 on macOS, sets `JAVA_HOME` for this shell only, prints `java -version`, runs `mvn clean verify`, and runs the demo app.

**Watch the terminal. Confirm:**

1. **`java -version` shows Oracle:**
   ```
   java version "17.0.x" ... LTS
   Java(TM) SE Runtime Environment ...
   ```
   If you see `Eclipse Adoptium` or `Red Hat`, JAVA_HOME is wrong — stop and fix it.

2. **`mvn clean verify` succeeds:**
   ```
   [INFO] Tests run: 8, Failures: 0, Errors: 0, Skipped: 0
   [INFO] BUILD SUCCESS
   ```

3. **Demo app output shows the Oracle vendor string:**
   ```
   Java version : 17.0.x
   Java vendor  : Oracle Corporation
   Java home    : /Library/Java/.../jdk-17.0.x.jdk/Contents/Home
   ...
   Demo complete.
   ```

**Say:** "Green baseline on Oracle JDK 17 — 8 tests pass, app runs. Any difference on the RHEL VM is attributable to the migration. If this fails, I don't continue."

**If it fails:** do not continue. See Troubleshooting.

---

## 3. Point to the pre-captured baseline on the dashboard (1 min)

The before-panel is already filled in from the capture run done before the demo. Open `demo/results.js` and show the audience — briefly — that the values are hand-entered from a real run, not auto-generated.

**Say:** "I record these manually because nothing should auto-populate. The Oracle vendor string, the version number, the test count — every value here came directly from terminal output I captured before you arrived. The raw output is in `demo/evidence/before-build.txt` if you want to verify it."

**Show briefly in the browser:**
- Section B "Before" panel: `Oracle Corporation`, `17.0.20.1`, green Passed badges for Build and Tests
- Section E Evidence strip: the timestamp `2026-10-23 11:26 PDT` and the before-side values

If the before-panel shows "Not yet verified" instead of green badges, `demo/results.js` was reset — re-run `./scripts/capture-baseline.sh`, copy the values back, and refresh.

---

## 4. IBM Bob: assess the project (3 min) — Bob-dependent

In IBM Bob, with this folder open, use the Java Modernization workflow. Suggested prompt:

> Assess this project for migration from Oracle JDK 17 to Red Hat build of OpenJDK 17 and report any real compatibility concerns.

**Say while it runs:** "Bob reads the build configuration, source code, and test files. It looks for vendor-specific APIs, JVM flags, JAVA_HOME references, container or CI configuration — anything that could be Oracle-specific."

**What Bob might look at (examples, not predictions):**
- `pom.xml` compiler and toolchain settings
- Source code for use of `com.sun.*` or `sun.*` internal APIs
- Scripts for hardcoded Oracle paths or JVM flags
- README or Dockerfile references to Oracle JDK

**Handle either outcome honestly:**

- **Bob reports no concerns:** Say "This is the expected result for an application using only standard Java 17 APIs. Moving between vendor builds of the same Java version doesn't require code changes when no Oracle-specific APIs are used. The value here is that Bob gave a structured answer, not a guess."

- **Bob reports items:** Read each one. Check it against the code before accepting. If a finding doesn't match what's in the source, say so. Record only what is genuine.

Record Bob's actual report:
```js
assessment: {
  status:   "info",          // or "passed", "pending" — whatever fits
  summary:  "...",           // one or two sentences from Bob's actual report
  findings: []               // list of actual concerns, or [] if none
},
```

Refresh the browser. Section C will show the assessment summary and any findings (or a green "no concerns" note).

---

## 5. IBM Bob: review any changes (2 min) — Bob-dependent

Check whether Bob applied or suggested any changes:

```bash
git status
git diff
```

**Two possible outcomes:**

**No changes:** `git status` is clean. 
Say: "No code or configuration changes were identified as required. That's a positive result — the assessment and the runtime validation together provide the confidence, without unnecessary changes."

Record:
```js
changes: {
  status:  "info",
  summary: "No source or configuration changes were required.",
  files:   []
},
```

**Changes were suggested or applied:** `git diff` shows what changed. Walk through each file. Explain what changed and why. Accept only what you can justify.

Record:
```js
changes: {
  status:  "passed",
  summary: "One configuration change applied.",
  files:   [
    { path: "pom.xml", note: "what changed", reason: "why it was needed", bobAssisted: true }
  ]
},
```

Refresh the browser. Section C will show either the no-changes confirmation or the file-level change list.

---

## 6. Validate on Red Hat OpenJDK 17 — RHEL 9.6 VM (3 min)

Switch to the terminal with SSH access to the RHEL 9.6 VM.

```bash
# On the RHEL VM:
cd ~/java-modernization-demo
./scripts/validate-rhel.sh
```

Or manually:
```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH="$JAVA_HOME/bin:$PATH"
java -version           # confirm Red Hat, Inc.
mvn -version            # confirm Java vendor: Red Hat, Inc.
mvn clean verify
java -jar target/java-modernization-demo-1.0.0.jar
```

**Watch the terminal. Confirm:**

1. **`java -version` shows Red Hat:**
   ```
   openjdk version "17.0.x" ...
   OpenJDK Runtime Environment (Red Hat) ...
   ```

2. **`mvn clean verify` succeeds:**
   ```
   [INFO] Tests run: 8, Failures: 0, Errors: 0, Skipped: 0
   [INFO] BUILD SUCCESS
   ```

3. **Demo app output shows the Red Hat vendor string:**
   ```
   Java version : 17.0.20.1
   Java vendor  : Red Hat, Inc.
   Java home    : /usr/lib/jvm/java-17-openjdk-17.0.20.1.1-1.1.el9.x86_64
   ...
   Demo complete.
   ```

**Say:** "Same source code, same test suite — now compiled and run on Red Hat OpenJDK 17 on RHEL 9.6. The vendor string changed; everything else stayed green."

**If the build or tests fail:** That is a real finding. Show the error, record it as Failed, and discuss it. Do not hide it.

---

## 7. Dashboard: show the verified outcome (1–2 min)

Back on macOS, edit `demo/results.js` with the values you just observed on the RHEL VM:

```js
after: {
  vendor:          "Red Hat, Inc.",          // exact java.vendor from the VM
  version:         "17.0.20.1",             // exact java.version from the VM
  runtimeDetected: "openjdk version \"17.0.20.1\" ...",  // first line of java -version
  build:  { status: "passed", detail: "mvn clean verify: BUILD SUCCESS" },
  tests:  { status: "passed", detail: "8 run, 0 failures, 0 errors, 0 skipped" },
  appRun: { status: "passed", detail: "App started, Red Hat vendor string confirmed, Demo complete." },
  followUps: []    // e.g. ["Update CI pipeline to use ubi9/openjdk-17 base image"]
},
outcome: {
  summary: "Application migrated to Red Hat OpenJDK 17 on RHEL 9.6 with no source changes required."
}
```

Refresh the browser.

**Expect:** The outcome banner at the top turns green: "Validated — build and unit tests passed on Red Hat OpenJDK 17 (RHEL 9.6)."

**Walk through the dashboard:**
- **Section A:** The journey — Oracle → Bob → Red Hat
- **Section B:** Before/After comparison — both panels show Passed with real vendor strings
- **Section C:** What Bob found and what was changed (or confirmed no changes needed)
- **Section D:** Impact summary — compatibility, Bob's role, validation evidence, remaining risk
- **Section E:** Evidence strip — every recorded value with the timestamp

**Say:** "Findings are what Bob reported. Changes are what was actually applied and why. Verified outcomes are real build and test runs. Each is shown separately so you can see exactly what is evidence and what is explanation."

---

## 8. Wrap up and reset

**Say:**
- "Bob gave a structured compatibility assessment in minutes, not days."
- "The test suite provided objective evidence — not assumptions — about runtime compatibility."
- "For this application, [no changes were needed / these specific changes were needed] — and we know that from evidence, not guesswork."
- "Before production: full integration tests, container base image updates, CI pipeline JDK references, and a support contract review for Red Hat OpenJDK."

**Reset for the next run:**
```bash
./scripts/reset-demo.sh
```

Type `reset` when prompted. This restores `pom.xml` and `src/` from the baseline tag, clears `demo/results.js`, and removes `target/`. Git history and all other files are untouched.

---

## Likely audience questions

| Question | Honest answer |
|---|---|
| Will our code need changes? | Not necessarily. Standard Java APIs behave identically across JDK 17 builds. Real issues tend to be in vendor-specific APIs (e.g., `com.sun.*`), JVM flags, build/CI config, or container base images. Bob's assessment tells you for your specific code. |
| Is this a Java version upgrade? | No. Both sides are Java 17. This is a vendor migration: Oracle JDK → Red Hat build of OpenJDK. No new language features or API changes are involved. |
| Was the Oracle baseline actually Oracle? | Only if the `java -version` output and `java.vendor` on screen said "Oracle Corporation." The script exits immediately if Oracle JDK 17 is not found. |
| Was the RHEL VM actually Red Hat? | Only if `java.vendor` on the VM reported "Red Hat, Inc." The dashboard shows a warning if the recorded vendor doesn't match. |
| Does this prove production readiness? | No. It shows this application builds, passes 8 unit tests, and starts correctly. Production readiness needs the full integration test suite, performance benchmarks, and a support contract review. |
| What about containers? | Container base images (e.g., `openjdk:17-jdk-slim`) may reference Oracle-derived images. Switching to `ubi9/openjdk-17` or `registry.access.redhat.com/ubi9/openjdk-17` is the typical follow-up action. Bob can help assess that too. |
| Is the dashboard automated? | No. It displays hand-entered results from `demo/results.js`. Intentionally manual — nothing shows as Passed unless a real run supports it. |

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `run-oracle17.sh` exits with "Oracle JDK 17 not found" | Oracle JDK 17 not installed | See DEMO_GUIDE.md § 2a |
| `java -version` shows Eclipse Adoptium or Red Hat on macOS | JAVA_HOME not set correctly | Run `./scripts/run-oracle17.sh` which auto-sets it |
| `mvn: command not found` | Maven not on PATH | `export PATH=/opt/homebrew/bin:$PATH` |
| SSH connection to VM refused | VM not running or wrong IP | Check IBM Cloud console; verify VM is powered on |
| `validate-rhel.sh` exits with "Red Hat OpenJDK 17 not found" on VM | OpenJDK 17 not installed | `sudo dnf install java-17-openjdk-devel` |
| `mvn: command not found` on VM | Maven not installed | `sudo dnf install maven` |
| VM build fails: `release version 17 not supported` | JDK older than 17 active on VM | `export JAVA_HOME=/usr/lib/jvm/java-17-openjdk && export PATH="$JAVA_HOME/bin:$PATH"` |
| Maven cannot download artifacts on VM | No internet / Maven cache empty | Run once with network; or copy `~/.m2/repository` from macOS to VM |
| Dashboard blank or unchanged | Browser cache or JS syntax error in results.js | Hard-refresh (Cmd+Shift+R or Ctrl+Shift+R); check for missing commas |
| Outcome banner stays "pending" even after filling after fields | `appRun` field missing in older results.js | Add `appRun: { status: "passed", detail: "..." }` to the `after` block |
| Build fails after migration | A real compatibility finding | Show the error, record as Failed, discuss it — do not hide |

---

## Presenter checklist (print or keep beside you)

- [ ] Oracle JDK 17 installed; `./scripts/run-oracle17.sh version` shows Oracle Corporation
- [ ] `git status` clean and `./scripts/reset-demo.sh` run
- [ ] Oracle baseline run: `./scripts/run-oracle17.sh` — 8 tests, 0 failures, BUILD SUCCESS
- [ ] `demo/results.js` updated with Oracle results; dashboard before-panel shows green
- [ ] IBM Bob: Java Modernization workflow run; findings recorded in results.js
- [ ] Changes reviewed with `git status` / `git diff`; recorded in results.js
- [ ] RHEL VM: `./scripts/validate-rhel.sh` runs successfully — Red Hat vendor, 8 tests, BUILD SUCCESS
- [ ] `demo/results.js` updated with RHEL VM results; dashboard outcome banner turns green
- [ ] `./scripts/reset-demo.sh` run at end of demo
