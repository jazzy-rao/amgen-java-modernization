package com.amgen.demo.sample;

import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

/** In-memory service for creating, finding and updating lab samples. */
public class SampleService {

    /** Fictional ID format, e.g. SMP-1001. */
    private static final Pattern ID_PATTERN = Pattern.compile("SMP-\\d{4}");

    private final Map<String, LabSample> samples = new HashMap<>();

    public LabSample createSample(String id, String sampleType) {
        if (id == null || !ID_PATTERN.matcher(id).matches()) {
            throw new IllegalArgumentException("Invalid sample ID '" + id + "': expected format SMP-1234");
        }
        if (sampleType == null || sampleType.isBlank()) {
            throw new IllegalArgumentException("Sample type must not be blank");
        }
        if (samples.containsKey(id)) {
            throw new IllegalArgumentException("Sample already exists: " + id);
        }
        LabSample sample = new LabSample(id, sampleType.trim(), SampleStatus.RECEIVED);
        samples.put(id, sample);
        return sample;
    }

    public LabSample getSample(String id) {
        LabSample sample = id == null ? null : samples.get(id);
        if (sample == null) {
            throw new IllegalArgumentException("Sample not found: " + id);
        }
        return sample;
    }

    public LabSample updateStatus(String id, SampleStatus newStatus) {
        if (newStatus == null) {
            throw new IllegalArgumentException("Status must not be null");
        }
        LabSample sample = getSample(id);
        sample.setStatus(newStatus);
        return sample;
    }
}
