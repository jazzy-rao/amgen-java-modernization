/*
 * demo/results.template.js — blank template.
 *
 * reset-demo.sh copies this file over demo/results.js at the start of each demo run.
 * Do NOT edit this template to pre-fill results. Edit demo/results.js during the demo.
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
 */
window.DEMO_RESULTS = {
  updated: "",          // e.g. "2025-07-14 14:05 PDT" — fill in when you last edited this file

  outcome: {
    summary: ""         // optional one-sentence headline, written AFTER the full demo run is complete
  },

  // ── LEFT panel: Oracle JDK 17 baseline ─────────────────────────────────────
  before: {
    vendor:          "",    // observed java.vendor,         e.g. "Oracle Corporation"
    version:         "",    // observed java.version,        e.g. "17.0.12"
    runtimeDetected: "",    // first line of java -version,  e.g. "java version \"17.0.12\" 2024-07-16 LTS"
    build:  { status: "not-run", detail: "" },   // e.g. "mvn clean verify: BUILD SUCCESS"
    tests:  { status: "not-run", detail: "" }    // e.g. "8 run, 0 failures, 0 errors, 0 skipped"
  },

  // ── CENTER: IBM Bob assessment ──────────────────────────────────────────────
  assessment: {
    status:   "not-run",
    summary:  "",           // one or two sentences from Bob's actual report
    findings: []            // actual concerns Bob reported; [] if none
  },

  // ── CENTER: Migration changes actually applied ──────────────────────────────
  changes: {
    status:  "not-run",
    summary: "",            // e.g. "No source changes needed" — only if true
    files:   []
    // { path: "pom.xml", note: "what changed", reason: "why it was needed", bobAssisted: true }
  },

  // ── RIGHT panel: Red Hat OpenJDK 17 on RHEL 9.6 ────────────────────────────
  after: {
    vendor:          "",    // observed java.vendor,  e.g. "Red Hat, Inc."
    version:         "",    // observed java.version, e.g. "17.0.20.1"
    runtimeDetected: "",    // first line of java -version on the RHEL VM
    build:  { status: "not-run", detail: "" },
    tests:  { status: "not-run", detail: "" },
    appRun: { status: "not-run", detail: "" },  // e.g. "App printed Red Hat vendor string; Demo complete."
    followUps: []           // e.g. ["Update CI base image to ubi9/openjdk-17"]
  }
};
