package com.fieldnotes.controller;

import com.fieldnotes.dto.FieldNoteDto;
import com.fieldnotes.model.User;
import com.fieldnotes.service.AuthService;
import com.fieldnotes.service.FieldNoteService;
import com.fieldnotes.service.FileStorageService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Collections;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notes")
public class FieldNoteController {

    private final FieldNoteService fieldNoteService;
    private final AuthService authService;
    private final FileStorageService fileStorageService;

    public FieldNoteController(FieldNoteService fieldNoteService,
                               AuthService authService,
                               FileStorageService fileStorageService) {
        this.fieldNoteService = fieldNoteService;
        this.authService = authService;
        this.fileStorageService = fileStorageService;
    }

    @GetMapping
    public ResponseEntity<List<FieldNoteDto>> getNotes(
            @RequestParam(required = false) String query,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String siteId,
            @RequestParam(required = false) String customerId,
            @AuthenticationPrincipal UserDetails userDetails) {
        User user = authService.getCurrentUser(userDetails.getUsername());
        if ((query != null && !query.isBlank()) ||
            (status != null && !status.isBlank()) ||
            (siteId != null && !siteId.isBlank()) ||
            (customerId != null && !customerId.isBlank())) {
            return ResponseEntity.ok(fieldNoteService.searchAndFilterNotes(user.getId(), query, status, siteId, customerId));
        }
        return ResponseEntity.ok(fieldNoteService.getAllNotes(user.getId()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<FieldNoteDto> getNoteById(@PathVariable String id,
                                                    @AuthenticationPrincipal UserDetails userDetails) {
        User user = authService.getCurrentUser(userDetails.getUsername());
        return ResponseEntity.ok(fieldNoteService.getNoteById(id, user.getId()));
    }

    @PostMapping
    public ResponseEntity<FieldNoteDto> createNote(@Valid @RequestBody FieldNoteDto dto,
                                                   @AuthenticationPrincipal UserDetails userDetails) {
        User user = authService.getCurrentUser(userDetails.getUsername());
        return ResponseEntity.ok(fieldNoteService.createNote(dto, user));
    }

    @PutMapping("/{id}")
    public ResponseEntity<FieldNoteDto> updateNote(@PathVariable String id,
                                                   @Valid @RequestBody FieldNoteDto dto,
                                                   @AuthenticationPrincipal UserDetails userDetails) {
        User user = authService.getCurrentUser(userDetails.getUsername());
        return ResponseEntity.ok(fieldNoteService.updateNote(id, dto, user.getId()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteNote(@PathVariable String id,
                                           @AuthenticationPrincipal UserDetails userDetails) {
        User user = authService.getCurrentUser(userDetails.getUsername());
        fieldNoteService.deleteNote(id, user.getId());
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/upload-photo")
    public ResponseEntity<Map<String, String>> uploadPhoto(
            @RequestParam("file") MultipartFile file) {
        String photoUrl = fileStorageService.storeFile(file);
        return ResponseEntity.ok(Collections.singletonMap("photoUrl", photoUrl));
    }
}

