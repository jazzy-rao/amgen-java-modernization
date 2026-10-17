# Demo Guide: Java Modernization Baseline

## Original configuration
| Item | Value |
|---|---|
| Java target | 17 (`<java.version>17</java.version>` in `pom.xml`, applied via `maven.compiler.release`) |
| Build tool | Maven (built here with 3.9.9) |
| Test framework | JUnit Jupiter 5.10.2 |
| Plugins | maven-compiler 3.12.1, surefire 3.2.5, jar 3.3.0 |
| Dependencies | JUnit only (test scope) |
| Runtime dependencies | none |

**Baseline environment caveat:** the baseline was prepared on Eclipse Temurin 21.0.12.1 (the only JDK installed on the prep machine), compiling with `--release 17` (class files are major version 61 = Java 17). It was **not** run on Oracle JDK 17. For a true "Oracle JDK" baseline, install Oracle JDK 17 and point `JAVA_HOME` at it before step 2 below, so the captured evidence shows the Oracle vendor string.

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
src/main/java/com/amgen/demo/sample/{DemoApp,SampleService,LabSample,SampleStatus}.java
src/test/java/com/amgen/demo/sample/SampleServiceTest.java
```

## How the baseline is saved
The original working project is the Git commit `b653fec`, protected by the annotated tag **`demo-baseline`**.

- Reset restores `pom.xml` and `src/` from that tag, resets `demo/results.js` from its template, and deletes `target/`.
- Reset never touches `.git`, `README.md`, `DEMO_GUIDE.md`, `demo/index.html`, `scripts/`, or anything outside this folder.
- Reset never commits, never runs Maven or Bob, and never starts a migration.
- If files differ from the baseline, reset lists them and requires you to type `reset` before overwriting anything.
- Because the tag does not move when you commit during a run, every run starts from the same baseline. To inspect it: `git show demo-baseline --stat`.
- To change the baseline deliberately (not normally needed): `git tag -f -a demo-baseline <commit> -m "..."`.

## Presentation checklist

### 1. Reset the project
```bash
./scripts/reset-demo.sh          # macOS/Linux
pwsh ./scripts/reset-demo.ps1    # Windows (PowerShell 7; or powershell.exe -File .\scripts\reset-demo.ps1)
```
It lists anything it will overwrite and asks you to type `reset`. If Maven isn't on your PATH:
`export PATH=~/.m2/wrapper/dists/apache-maven-3.9.9/3477a4f1/bin:$PATH`

### 2. Verify the Oracle JDK baseline and run tests
```bash
java -version
mvn -version
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

### 6. Switch to or configure the Red Hat OpenJDK target
Use the supported workflow from step 4 to apply or guide this. Then confirm the runtime:
```bash
java -version      # should show a Red Hat build of OpenJDK 17
echo $JAVA_HOME
mvn -version       # check the "runtime:" line
```
Setting up the target JDK (installation, `JAVA_HOME`) is a manual step on your machine unless the workflow does it.

### 7. Run the build and tests again
```bash
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
2. `pom.xml`: the Java version property and plugin versions, with no vendor-specific settings
3. `DemoApp.java`: prints `java.version`, `java.vendor`, `java.home`
4. `SampleService.java`: plain Java business logic
5. `SampleServiceTest.java`: the safety net that validates the migration

## Evidence to capture before migration
- `java -version` and `mvn -version` output (vendor, version, `java.home`)
- `mvn clean verify` result: 8 tests, 0 failures
- Demo output from `java -jar ...`
- Class file level: `javap -v -cp target/classes com.amgen.demo.sample.DemoApp | grep "major version"` (expect 61)
- `git status` and the current commit hash

After migration, repeat the same commands and compare. The vendor and `java.home` lines are expected to change. Source changes are not necessarily expected: this app uses only standard Java APIs, so a migration may legitimately need none. Report what Bob actually finds.
