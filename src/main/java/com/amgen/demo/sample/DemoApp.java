package com.amgen.demo.sample;

/** Runs a short, readable terminal demonstration. */
public class DemoApp {

    public static void main(String[] args) {
        System.out.println("==============================================");
        System.out.println(" Lab Sample Tracker - Java Modernization Demo");
        System.out.println("==============================================");
        System.out.println("Java version : " + System.getProperty("java.version"));
        System.out.println("Java vendor  : " + System.getProperty("java.vendor"));
        System.out.println("Java home    : " + System.getProperty("java.home"));
        System.out.println();

        SampleService service = new SampleService();

        System.out.println("[1] Create samples");
        System.out.println("    " + service.createSample("SMP-1001", "Blood Plasma"));
        System.out.println("    " + service.createSample("SMP-1002", "Cell Culture"));

        System.out.println("[2] Retrieve sample SMP-1001");
        System.out.println("    " + service.getSample("SMP-1001"));

        System.out.println("[3] Update status of SMP-1001");
        System.out.println("    " + service.updateStatus("SMP-1001", SampleStatus.IN_PROGRESS));
        System.out.println("    " + service.updateStatus("SMP-1001", SampleStatus.COMPLETED));

        System.out.println("[4] Invalid input handling");
        tryAndReport(() -> service.createSample("BAD-ID", "Serum"));
        tryAndReport(() -> service.createSample("SMP-1003", " "));
        tryAndReport(() -> service.getSample("SMP-9999"));

        System.out.println();
        System.out.println("Demo complete.");
    }

    private static void tryAndReport(Runnable action) {
        try {
            action.run();
        } catch (IllegalArgumentException e) {
            System.out.println("    Rejected: " + e.getMessage());
        }
    }
}
