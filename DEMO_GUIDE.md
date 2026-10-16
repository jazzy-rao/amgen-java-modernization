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

**Baseline environment caveat:** the baseline was produced on Eclipse Temurin 21.0.12.1 (the only JDK installed on the prep machine), compiling with `--release 17` (class files are major version 61 = Java 17). It was **not** run on Oracle JDK 17. If you want to present a true "Oracle JDK" baseline, install Oracle JDK 17 and re-run the baseline commands below before migrating, so the captured evidence shows the Oracle vendor string.

## Project structure
```
pom.xml
README.md
DEMO_GUIDE.md
src/main/java/com/amgen/demo/sample/{DemoApp,SampleService,LabSample,SampleStatus}.java
src/test/java/com/amgen/demo/sample/SampleServiceTest.java
```

## Baseline commands
```bash
java -version
mvn -version
mvn clean verify                                   # compile + 8 tests + jar
java -jar target/java-modernization-demo-1.0.0.jar # terminal demo
```

## Files to show during the presentation
1. `pom.xml` — Java version property, plugin versions, no vendor-specific settings.
2. `DemoApp.java` — prints `java.version`, `java.vendor`, `java.home`; this makes the runtime change visible.
3. `SampleService.java` — representative business logic (plain Java, no vendor APIs).
4. `SampleServiceTest.java` — the safety net that validates the migration.

## Evidence to capture before migration
- `java -version` and `mvn -version` output (vendor, version, `java.home`).
- `mvn clean verify` result: 8 tests, 0 failures.
- Demo output from `java -jar ...`, especially the Java version/vendor/home lines.
- Class file target level (`javap -v -cp target/classes com.amgen.demo.sample.DemoApp | grep "major version"` → 61).
- `git status` clean and the initial commit hash.

After migration, repeat the same commands and compare. Expect the vendor/home lines to change. Do not expect code changes: this app uses only standard Java APIs and no known Oracle-specific features, so a migration may legitimately require none. Let Bob's analysis report what it actually finds.
