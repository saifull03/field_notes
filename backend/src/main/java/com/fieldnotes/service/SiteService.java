package com.fieldnotes.service;

import com.fieldnotes.dto.SiteDto;
import com.fieldnotes.model.Customer;
import com.fieldnotes.model.Site;
import com.fieldnotes.model.User;
import com.fieldnotes.repository.CustomerRepository;
import com.fieldnotes.repository.SiteRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class SiteService {

    private final SiteRepository siteRepository;
    private final CustomerRepository customerRepository;

    public SiteService(SiteRepository siteRepository, CustomerRepository customerRepository) {
        this.siteRepository = siteRepository;
        this.customerRepository = customerRepository;
    }

    @Transactional(readOnly = true)
    public List<SiteDto> getAllSites(Long userId) {
        return siteRepository.findByCustomerUserIdAndDeletedFalseOrderByNameAsc(userId)
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<SiteDto> getSitesByCustomer(String customerId, Long userId) {
        Customer customer = customerRepository.findByIdAndUserId(customerId, userId)
                .orElseThrow(() -> new IllegalArgumentException("Customer not found or not owned by user: " + customerId));

        return siteRepository.findByCustomerIdAndDeletedFalseOrderByNameAsc(customer.getId())
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public SiteDto getSiteById(String id, Long userId) {
        Site site = siteRepository.findByIdAndCustomerUserId(id, userId)
                .filter(s -> !s.isDeleted())
                .orElseThrow(() -> new IllegalArgumentException("Site not found: " + id));
        return toDto(site);
    }

    @Transactional
    public SiteDto createSite(SiteDto dto, User user) {
        Customer customer = customerRepository.findByIdAndUserId(dto.getCustomerId(), user.getId())
                .orElseThrow(() -> new IllegalArgumentException("Customer not found or access denied: " + dto.getCustomerId()));

        String id = (dto.getId() != null && !dto.getId().isBlank()) ? dto.getId() : UUID.randomUUID().toString();
        Site site = new Site(
                id,
                customer,
                dto.getName(),
                dto.getAddress()
        );
        if (dto.getCreatedAt() != null) {
            site.setCreatedAt(dto.getCreatedAt());
        }
        if (dto.getUpdatedAt() != null) {
            site.setUpdatedAt(dto.getUpdatedAt());
        }
        site.setDeleted(dto.isDeleted());

        Site saved = siteRepository.save(site);
        return toDto(saved);
    }

    @Transactional
    public SiteDto updateSite(String id, SiteDto dto, Long userId) {
        Site site = siteRepository.findByIdAndCustomerUserId(id, userId)
                .orElseThrow(() -> new IllegalArgumentException("Site not found: " + id));

        if (dto.getCustomerId() != null && !dto.getCustomerId().equals(site.getCustomer().getId())) {
            Customer customer = customerRepository.findByIdAndUserId(dto.getCustomerId(), userId)
                    .orElseThrow(() -> new IllegalArgumentException("Customer not found: " + dto.getCustomerId()));
            site.setCustomer(customer);
        }

        site.setName(dto.getName());
        site.setAddress(dto.getAddress());
        site.setDeleted(dto.isDeleted());
        site.setUpdatedAt(dto.getUpdatedAt() != null ? dto.getUpdatedAt() : Instant.now());

        Site updated = siteRepository.save(site);
        return toDto(updated);
    }

    @Transactional
    public void deleteSite(String id, Long userId) {
        Site site = siteRepository.findByIdAndCustomerUserId(id, userId)
                .orElseThrow(() -> new IllegalArgumentException("Site not found: " + id));

        site.setDeleted(true);
        site.setUpdatedAt(Instant.now());
        site.getNotes().forEach(note -> {
            note.setDeleted(true);
            note.setUpdatedAt(Instant.now());
        });
        siteRepository.save(site);
    }

    public SiteDto toDto(Site site) {
        int noteCount = 0;
        if (site.getNotes() != null) {
            noteCount = (int) site.getNotes().stream().filter(n -> !n.isDeleted()).count();
        }

        return new SiteDto(
                site.getId(),
                site.getCustomer().getId(),
                site.getCustomer().getName(),
                site.getName(),
                site.getAddress(),
                noteCount,
                site.isDeleted(),
                site.getCreatedAt(),
                site.getUpdatedAt()
        );
    }
}
