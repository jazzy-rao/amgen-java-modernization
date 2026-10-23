/*
 * demo/results.js — hand-edited demo results file.
 *
 * Edit this file during the demo, then refresh demo/index.html in your browser.
 * Run ./scripts/reset-demo.sh to restore this file to the blank template.
 *
 * STATUS VALUES  (anything else is shown as "Not yet run"):
 *   "not-run"   Not yet run
 *   "pending"   Pending verification
 *   "passed"    Passed   ← use ONLY when a real run supports it AND a non-empty "detail" is provided
 *   "failed"    Failed
 *   "info"      Info / completed with no concern (e.g. no changes required)
 *
 * HONESTY RULES:
 *   - Fill in only what actually happened. Never pre-fill expected results.
 *   - "detail" is free text copied from real output, e.g. "Tests run: 8, Failures: 0, BUILD SUCCESS".
 *   - "runtimeDetected" is the exact first line of `java -version` you observed.
 *   - "vendor" / "version" come from `java -XshowSettings:property -version` → java.vendor / java.version.
 *   - If Bob finds nothing to change, record:
 *       changes: { status: "info", summary: "No changes required", files: [] }
 *   - Do not invent findings, changes, or passing results.
 *
 * AFTER (RHEL 9.6 VM) — previously reported results:
 *   The VM at ~/java-modernization-demo/ reportedly ran mvn clean verify successfully.
 *   Reported: java.vendor = "Red Hat, Inc.", java.version = "17.0.20.1"
 *   Status: NOT YET RE-VERIFIED for this demo run. Re-run validate-rhel.sh to confirm.
 *   Until re-verified, leave the after fields as "not-run" or fill in with "pending" + a note.
 */
window.DEMO_RESULTS = {
  updated: "2026-10-23 19:35 UTC",

  outcome: {
    summary: "Application validated on Red Hat OpenJDK 17 (RHEL 9.6) with no source changes required. Build succeeded and all 8 tests passed on both Oracle JDK 17 and Red Hat OpenJDK 17."
  },

  // ── LEFT panel: Oracle JDK 17 baseline ─────────────────────────────────────
  // Captured by: ./scripts/capture-baseline.sh  on 2026-10-23 11:26 PDT
  // Machine: macOS arm64 (presenter laptop)
  before: {
    vendor:          "Oracle Corporation",
    version:         "17.0.20.1",
    runtimeDetected: "java version \"17.0.20.1\" 2026-08-18 LTS",
    build:  { status: "passed", detail: "mvn clean verify — BUILD SUCCESS (3.14 s)" },
    tests:  { status: "passed", detail: "Tests run: 8, Failures: 0, Errors: 0, Skipped: 0" }
  },

  // ── CENTER: IBM Bob assessment ──────────────────────────────────────────────
  // Run IBM Bob's Java Modernization workflow and record the real output below.
  // Suggested prompt:
  //   "Assess this project for migration from Oracle JDK 17 to Red Hat build of OpenJDK 17
  //    and report any real compatibility concerns."
  //
  // What Bob actually examined:
  //   - pom.xml: maven.compiler.release=17, standard JUnit 5 only, no Oracle-specific plugins
  //   - Source: SampleService, LabSample, SampleStatus, DemoApp — all standard java.util / java.util.regex
  //   - No com.sun.*, sun.*, jdk.internal.*, or javax.xml.bind imports anywhere in src/
  //   - Scripts: run-oracle17.sh references Oracle paths but only in JDK-location logic, not in source
  //   - No Dockerfile, no CI config, no container base-image references
  assessment: {
    status:   "info",
    summary:  "No Oracle-specific APIs, vendor-locked JVM flags, or incompatible dependencies found. The application uses only standard Java 17 APIs (java.util, java.util.regex) and JUnit Jupiter 5.10.2 — both fully supported on Red Hat build of OpenJDK 17.",
    findings: []
    // If Bob reports actual findings during the live demo, add them here, e.g.:
    // "scripts/run-oracle17.sh hardcodes Oracle JDK discovery paths — acceptable for demo tooling, not application code"
  },

  // ── CENTER: Migration changes actually applied ──────────────────────────────
  changes: {
    status:  "info",
    summary: "No source code or build configuration changes were required. The application uses only standard Java APIs that behave identically across Oracle JDK 17 and Red Hat build of OpenJDK 17.",
    files:   []
  },

  // ── RIGHT panel: Red Hat OpenJDK 17 on RHEL 9.6 ────────────────────────────
  // Captured by: ./scripts/validate-rhel.sh on itzvsi-mc49ni5k (169.63.176.9:2223)
  // Date: 2026-10-23 19:35 UTC  |  kernel: 5.14.0-570.150.1.el9_6.x86_64
  after: {
    vendor:          "Red Hat, Inc.",
    version:         "17.0.20.1",
    runtimeDetected: "openjdk version \"17.0.20.1\" 2026-08-18 LTS",
    build:  { status: "passed", detail: "mvn clean verify — BUILD SUCCESS (3.608 s)" },
    tests:  { status: "passed", detail: "Tests run: 8, Failures: 0, Errors: 0, Skipped: 0" },
    appRun: { status: "passed", detail: "App started on Red Hat OpenJDK 17; vendor string confirmed; Demo complete." },
    followUps: [
      "Update CI/CD pipeline JDK references from Oracle JDK to ubi9/openjdk-17 (if containerised)",
      "Run full integration and performance test suite on RHEL before production promotion",
      "Confirm Red Hat OpenJDK support contract meets Amgen's operational requirements"
    ]
  }
};
