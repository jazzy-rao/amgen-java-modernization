# java-modernization-demo

A small, fictional laboratory sample tracker used to demonstrate moving a Java application from Oracle JDK to Red Hat build of OpenJDK with IBM Bob. All data is synthetic.

## What it does
- Create a sample (ID, type, status; new samples start as `RECEIVED`)
- Retrieve a sample by ID
- Update a sample's status (`RECEIVED`, `IN_PROGRESS`, `COMPLETED`, `REJECTED`)
- Reject invalid input with clear messages (bad ID format, blank type, duplicate ID, unknown ID, null status)

No database, network, frameworks or Docker. Plain Java 17 + Maven + JUnit 5.

## Prerequisites
- JDK 17 or later (the build targets Java 17 via `maven.compiler.release`)
- Maven 3.9+

Check with:
```bash
java -version
mvn -version
```

## Commands
```bash
# Build and run tests
mvn clean verify

# Run tests only
mvn test

# Package and run the demo
mvn clean package
java -jar target/java-modernization-demo-1.0.0.jar
```

## Configuration
The Java version is set in one place, `<java.version>` in [`pom.xml`](pom.xml).

## Layout
```
pom.xml
src/main/java/com/amgen/demo/sample/
  DemoApp.java        terminal demo (prints Java version/vendor/home)
  SampleService.java  business logic and validation
  LabSample.java      model
  SampleStatus.java   status enum
src/test/java/com/amgen/demo/sample/SampleServiceTest.java
```

See [`DEMO_GUIDE.md`](DEMO_GUIDE.md) for the presentation walkthrough.
