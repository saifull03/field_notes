package com.fieldnotes.service;

import com.fieldnotes.dto.*;
import com.fieldnotes.model.Customer;
import com.fieldnotes.model.FieldNote;
import com.fieldnotes.model.Site;
import com.fieldnotes.model.User;
import com.fieldnotes.repository.CustomerRepository;
import com.fieldnotes.repository.FieldNoteRepository;
import com.fieldnotes.repository.SiteRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class SyncService {

    private final CustomerRepository customerRepository;
    private final SiteRepository siteRepository;
    private final FieldNoteRepository fieldNoteRepository;
    private final CustomerService customerService;
    private final SiteService siteService;
    private final FieldNoteService fieldNoteService;

    public SyncService(CustomerRepository customerRepository,
                       SiteRepository siteRepository,
                       FieldNoteRepository fieldNoteRepository,
                       CustomerService customerService,
                       SiteService siteService,
                       FieldNoteService fieldNoteService) {
        this.customerRepository = customerRepository;
        this.siteRepository = siteRepository;
        this.fieldNoteRepository = fieldNoteRepository;
        this.customerService = customerService;
        this.siteService = siteService;
        this.fieldNoteService = fieldNoteService;
    }

    @Transactional(readOnly = true)
    public SyncPullResponse pullSync(User user, Instant since) {
        Instant serverTime = Instant.now();
        List<CustomerDto> customers;
        List<SiteDto> sites;
        List<FieldNoteDto> notes;

        if (since == null || since.toEpochMilli() <= 0) {
            // Full initial pull (e.g. app reinstall or fresh login)
            customers = customerRepository.findByUserIdAndDeletedFalseOrderByNameAsc(user.getId())
                    .stream().map(customerService::toDto).collect(Collectors.toList());
            sites = siteRepository.findByCustomerUserIdAndDeletedFalseOrderByNameAsc(user.getId())
                    .stream().map(siteService::toDto).collect(Collectors.toList());
            notes = fieldNoteRepository.findAllByUserIdWithDetails(user.getId())
                    .stream().map(fieldNoteService::toDto).collect(Collectors.toList());
        } else {
            // Delta pull (incremental updates since last sync, including deleted ones)
            customers = customerRepository.findByUserIdAndUpdatedAtAfter(user.getId(), since)
                    .stream().map(customerService::toDto).collect(Collectors.toList());
            sites = siteRepository.findByCustomerUserIdAndUpdatedAtAfter(user.getId(), since)
                    .stream().map(siteService::toDto).collect(Collectors.toList());
            notes = fieldNoteRepository.findByUserIdAndUpdatedAtAfter(user.getId(), since)
                    .stream().map(fieldNoteService::toDto).collect(Collectors.toList());
        }

        return new SyncPullResponse(serverTime, customers, sites, notes);
    }

    @Transactional
    public SyncPushResponse pushSync(User user, SyncPushRequest request) {
        Instant serverTime = Instant.now();
        List<String> syncedCustomers = new ArrayList<>();
        List<String> syncedSites = new ArrayList<>();
        List<String> syncedNotes = new ArrayList<>();

        // 1. Process Customers
        if (request.getCustomers() != null) {
            for (CustomerDto dto : request.getCustomers()) {
                String id = (dto.getId() != null && !dto.getId().isBlank()) ? dto.getId() : UUID.randomUUID().toString();
                Optional<Customer> existing = customerRepository.findByIdAndUserId(id, user.getId());

                Customer customer;
                if (existing.isPresent()) {
                    customer = existing.get();
                    if (dto.getUpdatedAt() == null || customer.getUpdatedAt() == null ||
                            !dto.getUpdatedAt().isBefore(customer.getUpdatedAt())) {
                        customer.setName(dto.getName());
                        customer.setContactInformation(dto.getContactInformation());
                        customer.setDeleted(dto.isDeleted());
                        customer.setUpdatedAt(dto.getUpdatedAt() != null ? dto.getUpdatedAt() : serverTime);
                    }
                } else {
                    customer = new Customer(id, user, dto.getName(), dto.getContactInformation());
                    if (dto.getCreatedAt() != null) customer.setCreatedAt(dto.getCreatedAt());
                    customer.setUpdatedAt(dto.getUpdatedAt() != null ? dto.getUpdatedAt() : serverTime);
                    customer.setDeleted(dto.isDeleted());
                }
                customerRepository.save(customer);
                syncedCustomers.add(id);
            }
        }

        // 2. Process Sites
        if (request.getSites() != null) {
            for (SiteDto dto : request.getSites()) {
                String id = (dto.getId() != null && !dto.getId().isBlank()) ? dto.getId() : UUID.randomUUID().toString();
                Optional<Customer> customerOpt = customerRepository.findByIdAndUserId(dto.getCustomerId(), user.getId());
                if (customerOpt.isEmpty()) {
                    continue; // Skip if parent customer not found
                }
                Customer customer = customerOpt.get();
                Optional<Site> existing = siteRepository.findByIdAndCustomerUserId(id, user.getId());

                Site site;
                if (existing.isPresent()) {
                    site = existing.get();
                    if (dto.getUpdatedAt() == null || site.getUpdatedAt() == null ||
                            !dto.getUpdatedAt().isBefore(site.getUpdatedAt())) {
                        site.setCustomer(customer);
                        site.setName(dto.getName());
                        site.setAddress(dto.getAddress());
                        site.setDeleted(dto.isDeleted());
                        site.setUpdatedAt(dto.getUpdatedAt() != null ? dto.getUpdatedAt() : serverTime);
                    }
                } else {
                    site = new Site(id, customer, dto.getName(), dto.getAddress());
                    if (dto.getCreatedAt() != null) site.setCreatedAt(dto.getCreatedAt());
                    site.setUpdatedAt(dto.getUpdatedAt() != null ? dto.getUpdatedAt() : serverTime);
                    site.setDeleted(dto.isDeleted());
                }
                siteRepository.save(site);
                syncedSites.add(id);
            }
        }

        // 3. Process Field Notes
        if (request.getNotes() != null) {
            for (FieldNoteDto dto : request.getNotes()) {
                String id = (dto.getId() != null && !dto.getId().isBlank()) ? dto.getId() : UUID.randomUUID().toString();
                Optional<Site> siteOpt = siteRepository.findByIdAndCustomerUserId(dto.getSiteId(), user.getId());
                if (siteOpt.isEmpty()) {
                    continue; // Skip if parent site not found
                }
                Site site = siteOpt.get();
                Optional<FieldNote> existing = fieldNoteRepository.findByIdAndUserIdWithDetails(id, user.getId());

                FieldNote note;
                if (existing.isPresent()) {
                    note = existing.get();
                    if (dto.getUpdatedAt() == null || note.getUpdatedAt() == null ||
                            !dto.getUpdatedAt().isBefore(note.getUpdatedAt())) {
                        note.setSite(site);
                        note.setTitle(dto.getTitle());
                        note.setDescription(dto.getDescription());
                        note.setLatitude(dto.getLatitude());
                        note.setLongitude(dto.getLongitude());
                        note.setLocationName(dto.getLocationName());
                        if (dto.getDateTime() != null) note.setDateTime(dto.getDateTime());
                        if (dto.getStatus() != null) note.setStatus(dto.getStatus());
                        if (dto.getPhotoUrl() != null) note.setPhotoUrl(dto.getPhotoUrl());
                        note.setDeleted(dto.isDeleted());
                        note.setUpdatedAt(dto.getUpdatedAt() != null ? dto.getUpdatedAt() : serverTime);
                    }
                } else {
                    note = new FieldNote(
                            id,
                            site,
                            dto.getTitle(),
                            dto.getDescription(),
                            dto.getLatitude(),
                            dto.getLongitude(),
                            dto.getLocationName(),
                            dto.getDateTime() != null ? dto.getDateTime() : serverTime,
                            dto.getStatus() != null ? dto.getStatus() : "Draft",
                            dto.getPhotoUrl()
                    );
                    if (dto.getCreatedAt() != null) note.setCreatedAt(dto.getCreatedAt());
                    note.setUpdatedAt(dto.getUpdatedAt() != null ? dto.getUpdatedAt() : serverTime);
                    note.setDeleted(dto.isDeleted());
                }
                fieldNoteRepository.save(note);
                syncedNotes.add(id);
            }
        }

        return new SyncPushResponse(serverTime, true, syncedCustomers, syncedSites, syncedNotes);
    }
}

