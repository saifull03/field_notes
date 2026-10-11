package com.fieldnotes.dto;

import java.util.ArrayList;
import java.util.List;

public class SyncPushRequest {
    private List<CustomerDto> customers = new ArrayList<>();
    private List<SiteDto> sites = new ArrayList<>();
    private List<FieldNoteDto> notes = new ArrayList<>();

    public SyncPushRequest() {}

    public List<CustomerDto> getCustomers() { return customers; }
    public void setCustomers(List<CustomerDto> customers) { this.customers = customers; }

    public List<SiteDto> getSites() { return sites; }
    public void setSites(List<SiteDto> sites) { this.sites = sites; }

    public List<FieldNoteDto> getNotes() { return notes; }
    public void setNotes(List<FieldNoteDto> notes) { this.notes = notes; }
}

