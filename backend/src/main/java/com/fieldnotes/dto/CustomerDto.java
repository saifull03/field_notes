package com.fieldnotes.dto;

import jakarta.validation.constraints.NotBlank;
import java.time.Instant;

public class CustomerDto {
    private String id;

    @NotBlank(message = "Customer name is required")
    private String name;

    private String contactInformation;
    private int siteCount;
    private int noteCount;
    private boolean deleted;
    private Instant createdAt;
    private Instant updatedAt;

    public CustomerDto() {}

    public CustomerDto(String id, String name, String contactInformation, int siteCount, int noteCount, boolean deleted, Instant createdAt, Instant updatedAt) {
        this.id = id;
        this.name = name;
        this.contactInformation = contactInformation;
        this.siteCount = siteCount;
        this.noteCount = noteCount;
        this.deleted = deleted;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getContactInformation() { return contactInformation; }
    public void setContactInformation(String contactInformation) { this.contactInformation = contactInformation; }

    public int getSiteCount() { return siteCount; }
    public void setSiteCount(int siteCount) { this.siteCount = siteCount; }

    public int getNoteCount() { return noteCount; }
    public void setNoteCount(int noteCount) { this.noteCount = noteCount; }

    public boolean isDeleted() { return deleted; }
    public void setDeleted(boolean deleted) { this.deleted = deleted; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}

