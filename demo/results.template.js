/*
 * DEMO RESULTS - edit demo/results.js (NOT this template) during the demo, then refresh index.html.
 * scripts/reset-demo.sh copies this template over demo/results.js, so every run starts as "Not yet run".
 *
 * status values (anything else is shown as "Not yet run"):
 *   "not-run"  -> Not yet run
 *   "pending"  -> Pending verification
 *   "passed"   -> Passed   (use ONLY when a real build/test run supports it)
 *   "failed"   -> Failed
 *   "info"     -> Info / completed with no issue to report
 *
 * Fill in only what actually happened. Leave arrays empty if nothing was found or changed.
 * "detail" is free text, e.g. "mvn clean verify: 8 tests, 0 failures".
 * "runtimeDetected" is the exact `java -version` first line you observed.
 */
window.DEMO_RESULTS = {
  updated: "",                       // e.g. "2025-01-31 14:05" - when you last edited this file

  before: {                          // LEFT: Oracle JDK 17 baseline
    runtimeDetected: "",             // e.g. 'java version "17.0.x" ...' from `java -version`
    build: { status: "not-run", detail: "" },
    tests: { status: "not-run", detail: "" }
  },

  assessment: {                      // CENTER: Bob's assessment
    status: "not-run",
    summary: "",                     // one or two sentences copied from Bob's report
    findings: []                     // actual compatibility concerns Bob reported, e.g. ["Text of finding 1"]
                                     // leave [] if none; set status "info" and summary "No concerns reported"
  },

  changes: {                         // CENTER: migration changes
    status: "not-run",
    summary: "",                     // e.g. "No source changes were needed" (only if true)
    files: []                        // actual files changed, e.g. [{ path: "pom.xml", note: "what changed" }]
  },

  after: {                           // RIGHT: Red Hat OpenJDK 17 target
    runtimeDetected: "",             // e.g. 'openjdk version "17.0.x" ... Red Hat ...'
    build: { status: "not-run", detail: "" },
    tests: { status: "not-run", detail: "" },
    followUps: []                    // remaining issues / actions, e.g. ["Update CI base image"]
  }
};
