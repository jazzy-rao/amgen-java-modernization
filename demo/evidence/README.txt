demo/evidence/
==============

This directory holds sanitized text evidence from actual build and test runs.
Files here are referenced by the dashboard (demo/index.html via demo/results.js)
and by the DEMO_SCRIPT.md presenter guide.

Files populated by scripts:
  before-java-version.txt   Oracle JDK 17: output of `java -version`
  before-mvn-version.txt    Oracle JDK 17: output of `mvn -version`
  before-build.txt          Oracle JDK 17: tail of `mvn clean verify` (tests + result)
  before-app.txt            Oracle JDK 17: demo app output (shows java.vendor)

  after-java-version.txt    Red Hat OpenJDK 17 (RHEL 9.6): `java -version`
  after-mvn-version.txt     Red Hat OpenJDK 17 (RHEL 9.6): `mvn -version`
  after-build.txt           Red Hat OpenJDK 17 (RHEL 9.6): `mvn clean verify` tail
  after-app.txt             Red Hat OpenJDK 17 (RHEL 9.6): demo app output

How to populate:
  macOS (before):   ./scripts/capture-baseline.sh
  RHEL VM (after):  ./scripts/validate-rhel.sh
                    then copy the after-*.txt files from the VM to this directory.

The *.txt files in this directory are NOT auto-read by the browser dashboard.
They are plain-text evidence you refer to during the presentation and paste
key values from into demo/results.js.

DO NOT pre-populate with expected or invented results.
Only record what an actual run produced.
