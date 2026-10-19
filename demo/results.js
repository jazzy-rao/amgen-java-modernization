/*
 * DEMO RESULTS - edit demo/results.js (NOT this template) during the demo, then refresh index.html.
 * scripts/reset-demo.sh copies this template over demo/results.js, so every run starts as "Not yet run".
 *
 * status values (anything else is shown as "Not yet run"):
 *   "not-run"  -> Not yet run
 *   "pending"  -> Pending verification
 *   "passed"   -> Passed   (use ONLY when a real build/test run supports it; needs a non-empty "detail")
 *   "failed"   -> Failed
 *   "info"     -> Info / completed with no issue to report
 *
 * Fill in only what actually happened. Never pre-fill expected results.
 *   - "detail" is free text, e.g. "mvn clean verify: 8 tests, 0 failures".
 *   - "runtimeDetected" is the exact `java -version` first line you observed.
 *   - "vendor" / "version" are read from that same output (or `java -XshowSettings:properties` -> java.vendor).
 *
 * NO CHANGES NEEDED: if Bob finds nothing to change, record
 *   changes: { status: "info", summary: "<what Bob said>", files: [] }
 * The dashboard then shows "No code or configuration changes were identified as required".
 * Do not invent a change just to fill the section.
 */
window.DEMO_RESULTS = {
  updated: "",                       // e.g. "2025-01-31 14:05" - when you last edited this file

  outcome: {
    summary: ""                      // optional one-sentence headline written by you AFTER validation
  },

  before: {                          // LEFT: Oracle JDK 17 baseline
    vendor: "",                      // e.g. observed java.vendor
    version: "",                     // e.g. observed java.version
    runtimeDetected: "",             // first line of `java -version`
    build: { status: "not-run", detail: "" },
    tests: { status: "not-run", detail: "" }
  },

  assessment: {                      // CENTER: Bob's assessment (FINDING)
    status: "not-run",
    summary: "",                     // one or two sentences copied from Bob's report
    findings: []                     // actual compatibility concerns Bob reported; [] if none
  },

  changes: {                         // CENTER: migration changes actually applied (CHANGE)
    status: "not-run",
    summary: "",                     // e.g. "No source changes were needed" (only if true)
    files: []                        // e.g. [{ path: "pom.xml", note: "what changed", reason: "why" }]
  },

  after: {                           // RIGHT: Red Hat OpenJDK 17 target
    vendor: "",
    version: "",
    runtimeDetected: "",             // first line of `java -version` on the target
    build: { status: "not-run", detail: "" },
    tests: { status: "not-run", detail: "" },
    followUps: []                    // remaining issues / actions, e.g. ["Update CI base image"]
  }
};
