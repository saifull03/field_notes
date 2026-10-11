package com.fieldnotes.dto;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

public class SyncPushResponse {
    private Instant serverTime = Instant.now();
    private boolean success = true;
    private List<String> syncedCustomerIds = new ArrayList<>();
    private List<String> syncedSiteIds = new ArrayList<>();
    private List<String> syncedNoteIds = new ArrayList<>();

    public SyncPushResponse() {}

    public SyncPushResponse(Instant serverTime, boolean success, List<String> syncedCustomerIds, List<String> syncedSiteIds, List<String> syncedNoteIds) {
        this.serverTime = serverTime;
        this.success = success;
        this.syncedCustomerIds = syncedCustomerIds;
        this.syncedSiteIds = syncedSiteIds;
        this.syncedNoteIds = syncedNoteIds;
    }

    public Instant getServerTime() { return serverTime; }
    public void setServerTime(Instant serverTime) { this.serverTime = serverTime; }

    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }

    public List<String> getSyncedCustomerIds() { return syncedCustomerIds; }
    public void setSyncedCustomerIds(List<String> syncedCustomerIds) { this.syncedCustomerIds = syncedCustomerIds; }

    public List<String> getSyncedSiteIds() { return syncedSiteIds; }
    public void setSyncedSiteIds(List<String> syncedSiteIds) { this.syncedSiteIds = syncedSiteIds; }

    public List<String> getSyncedNoteIds() { return syncedNoteIds; }
    public void setSyncedNoteIds(List<String> syncedNoteIds) { this.syncedNoteIds = syncedNoteIds; }
}
