package com.fieldnotes.dto;

import jakarta.validation.constraints.NotBlank;
import java.time.Instant;

public class FieldNoteDto {
    private String id;

    @NotBlank(message = "Site ID is required")
    private String siteId;

    private String siteName;
    private String customerId;
    private String customerName;

    @NotBlank(message = "Title is required")
    private String title;

    private String description;
    private Double latitude;
    private Double longitude;
    private String locationName;
    private Instant dateTime;
    private String status;
    private String photoUrl;
    private boolean deleted;
    private Instant createdAt;
    private Instant updatedAt;

    public FieldNoteDto() {}

    public FieldNoteDto(String id, String siteId, String siteName, String customerId, String customerName,
                        String title, String description, Double latitude, Double longitude, String locationName,
                        Instant dateTime, String status, String photoUrl, boolean deleted, Instant createdAt, Instant updatedAt) {
        this.id = id;
        this.siteId = siteId;
        this.siteName = siteName;
        this.customerId = customerId;
        this.customerName = customerName;
        this.title = title;
        this.description = description;
        this.latitude = latitude;
        this.longitude = longitude;
        this.locationName = locationName;
        this.dateTime = dateTime;
        this.status = status;
        this.photoUrl = photoUrl;
        this.deleted = deleted;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getSiteId() { return siteId; }
    public void setSiteId(String siteId) { this.siteId = siteId; }

    public String getSiteName() { return siteName; }
    public void setSiteName(String siteName) { this.siteName = siteName; }

    public String getCustomerId() { return customerId; }
    public void setCustomerId(String customerId) { this.customerId = customerId; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }

    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }

    public String getLocationName() { return locationName; }
    public void setLocationName(String locationName) { this.locationName = locationName; }

    public Instant getDateTime() { return dateTime; }
    public void setDateTime(Instant dateTime) { this.dateTime = dateTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }

    public boolean isDeleted() { return deleted; }
    public void setDeleted(boolean deleted) { this.deleted = deleted; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}

