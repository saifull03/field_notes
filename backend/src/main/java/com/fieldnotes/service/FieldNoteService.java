package com.fieldnotes.service;

import com.fieldnotes.dto.FieldNoteDto;
import com.fieldnotes.model.FieldNote;
import com.fieldnotes.model.Site;
import com.fieldnotes.model.User;
import com.fieldnotes.repository.FieldNoteRepository;
import com.fieldnotes.repository.SiteRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class FieldNoteService {

    private final FieldNoteRepository fieldNoteRepository;
    private final SiteRepository siteRepository;

    public FieldNoteService(FieldNoteRepository fieldNoteRepository, SiteRepository siteRepository) {
        this.fieldNoteRepository = fieldNoteRepository;
        this.siteRepository = siteRepository;
    }

    @Transactional(readOnly = true)
    public List<FieldNoteDto> getAllNotes(Long userId) {
        return fieldNoteRepository.findAllByUserIdWithDetails(userId)
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public FieldNoteDto getNoteById(String id, Long userId) {
        FieldNote note = fieldNoteRepository.findByIdAndUserIdWithDetails(id, userId)
                .filter(n -> !n.isDeleted())
                .orElseThrow(() -> new IllegalArgumentException("Field note not found: " + id));
        return toDto(note);
    }

    @Transactional(readOnly = true)
    public List<FieldNoteDto> searchAndFilterNotes(Long userId, String query, String status, String siteId, String customerId) {
        return fieldNoteRepository.searchNotes(userId, query, status, siteId, customerId)
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public FieldNoteDto createNote(FieldNoteDto dto, User user) {
        Site site = siteRepository.findByIdAndCustomerUserId(dto.getSiteId(), user.getId())
                .orElseThrow(() -> new IllegalArgumentException("Site not found or access denied: " + dto.getSiteId()));

        String id = (dto.getId() != null && !dto.getId().isBlank()) ? dto.getId() : UUID.randomUUID().toString();
        FieldNote note = new FieldNote(
                id,
                site,
                dto.getTitle(),
                dto.getDescription(),
                dto.getLatitude(),
                dto.getLongitude(),
                dto.getLocationName(),
                dto.getDateTime() != null ? dto.getDateTime() : Instant.now(),
                dto.getStatus() != null ? dto.getStatus() : "Draft",
                dto.getPhotoUrl()
        );
        if (dto.getCreatedAt() != null) {
            note.setCreatedAt(dto.getCreatedAt());
        }
        if (dto.getUpdatedAt() != null) {
            note.setUpdatedAt(dto.getUpdatedAt());
        }
        note.setDeleted(dto.isDeleted());

        FieldNote saved = fieldNoteRepository.save(note);
        return toDto(saved);
    }

    @Transactional
    public FieldNoteDto updateNote(String id, FieldNoteDto dto, Long userId) {
        FieldNote note = fieldNoteRepository.findByIdAndUserIdWithDetails(id, userId)
                .orElseThrow(() -> new IllegalArgumentException("Field note not found: " + id));

        if (dto.getSiteId() != null && !dto.getSiteId().equals(note.getSite().getId())) {
            Site site = siteRepository.findByIdAndCustomerUserId(dto.getSiteId(), userId)
                    .orElseThrow(() -> new IllegalArgumentException("Site not found or access denied: " + dto.getSiteId()));
            note.setSite(site);
        }

        note.setTitle(dto.getTitle());
        note.setDescription(dto.getDescription());
        note.setLatitude(dto.getLatitude());
        note.setLongitude(dto.getLongitude());
        note.setLocationName(dto.getLocationName());
        if (dto.getDateTime() != null) {
            note.setDateTime(dto.getDateTime());
        }
        if (dto.getStatus() != null) {
            note.setStatus(dto.getStatus());
        }
        if (dto.getPhotoUrl() != null) {
            note.setPhotoUrl(dto.getPhotoUrl());
        }
        note.setDeleted(dto.isDeleted());
        note.setUpdatedAt(dto.getUpdatedAt() != null ? dto.getUpdatedAt() : Instant.now());

        FieldNote updated = fieldNoteRepository.save(note);
        return toDto(updated);
    }

    @Transactional
    public void deleteNote(String id, Long userId) {
        FieldNote note = fieldNoteRepository.findByIdAndUserIdWithDetails(id, userId)
                .orElseThrow(() -> new IllegalArgumentException("Field note not found: " + id));

        note.setDeleted(true);
        note.setUpdatedAt(Instant.now());
        fieldNoteRepository.save(note);
    }

    public FieldNoteDto toDto(FieldNote note) {
        String siteId = note.getSite() != null ? note.getSite().getId() : null;
        String siteName = note.getSite() != null ? note.getSite().getName() : null;
        String customerId = (note.getSite() != null && note.getSite().getCustomer() != null) ? note.getSite().getCustomer().getId() : null;
        String customerName = (note.getSite() != null && note.getSite().getCustomer() != null) ? note.getSite().getCustomer().getName() : null;

        return new FieldNoteDto(
                note.getId(),
                siteId,
                siteName,
                customerId,
                customerName,
                note.getTitle(),
                note.getDescription(),
                note.getLatitude(),
                note.getLongitude(),
                note.getLocationName(),
                note.getDateTime(),
                note.getStatus(),
                note.getPhotoUrl(),
                note.isDeleted(),
                note.getCreatedAt(),
                note.getUpdatedAt()
        );
    }
}
