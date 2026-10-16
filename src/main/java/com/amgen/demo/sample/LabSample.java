package com.amgen.demo.sample;

/** A fictional laboratory sample. All data is synthetic. */
public class LabSample {

    private final String id;
    private final String sampleType;
    private SampleStatus status;

    public LabSample(String id, String sampleType, SampleStatus status) {
        this.id = id;
        this.sampleType = sampleType;
        this.status = status;
    }

    public String getId() {
        return id;
    }

    public String getSampleType() {
        return sampleType;
    }

    public SampleStatus getStatus() {
        return status;
    }

    void setStatus(SampleStatus status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return String.format("%s | %-12s | %s", id, sampleType, status);
    }
}
