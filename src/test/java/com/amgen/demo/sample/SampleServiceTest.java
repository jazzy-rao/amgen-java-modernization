package com.amgen.demo.sample;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class SampleServiceTest {

    private SampleService service;

    @BeforeEach
    void setUp() {
        service = new SampleService();
    }

    @Test
    void createSampleStartsAsReceived() {
        LabSample sample = service.createSample("SMP-1001", "Blood Plasma");
        assertEquals("SMP-1001", sample.getId());
        assertEquals("Blood Plasma", sample.getSampleType());
        assertEquals(SampleStatus.RECEIVED, sample.getStatus());
    }

    @Test
    void getSampleReturnsCreatedSample() {
        service.createSample("SMP-1001", "Serum");
        assertEquals("Serum", service.getSample("SMP-1001").getSampleType());
    }

    @Test
    void updateStatusChangesStatus() {
        service.createSample("SMP-1001", "Serum");
        service.updateStatus("SMP-1001", SampleStatus.COMPLETED);
        assertEquals(SampleStatus.COMPLETED, service.getSample("SMP-1001").getStatus());
    }

    @Test
    void invalidIdIsRejected() {
        IllegalArgumentException e =
                assertThrows(IllegalArgumentException.class, () -> service.createSample("BAD", "Serum"));
        assertTrue(e.getMessage().contains("expected format SMP-1234"));
    }

    @Test
    void blankTypeIsRejected() {
        assertThrows(IllegalArgumentException.class, () -> service.createSample("SMP-1001", " "));
    }

    @Test
    void duplicateIdIsRejected() {
        service.createSample("SMP-1001", "Serum");
        assertThrows(IllegalArgumentException.class, () -> service.createSample("SMP-1001", "Serum"));
    }

    @Test
    void unknownSampleIsRejected() {
        IllegalArgumentException e =
                assertThrows(IllegalArgumentException.class, () -> service.getSample("SMP-9999"));
        assertEquals("Sample not found: SMP-9999", e.getMessage());
    }

    @Test
    void nullStatusIsRejected() {
        service.createSample("SMP-1001", "Serum");
        assertThrows(IllegalArgumentException.class, () -> service.updateStatus("SMP-1001", null));
    }
}
