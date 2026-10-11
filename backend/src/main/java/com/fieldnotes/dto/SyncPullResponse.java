package com.fieldnotes.dto;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

public class SyncPullResponse {
    private Instant serverTime = Instant.now();
    private List<CustomerDto> customers = new ArrayList<>();
    private List<SiteDto> sites = new ArrayList<>();
    private List<FieldNoteDto> notes = new ArrayList<>();

    public SyncPullResponse() {}

    public SyncPullResponse(Instant serverTime, List<CustomerDto> customers, List<SiteDto> sites, List<FieldNoteDto> notes) {
        this.serverTime = serverTime;
        this.customers = customers;
        this.sites = sites;
        this.notes = notes;
    }

    public Instant getServerTime() { return serverTime; }
    public void setServerTime(Instant serverTime) { this.serverTime = serverTime; }

    public List<CustomerDto> getCustomers() { return customers; }
    public void setCustomers(List<CustomerDto> customers) { this.customers = customers; }

    public List<SiteDto> getSites() { return sites; }
    public void setSites(List<SiteDto> sites) { this.sites = sites; }

    public List<FieldNoteDto> getNotes() { return notes; }
    public void setNotes(List<FieldNoteDto> notes) { this.notes = notes; }
}

