package com.fieldnotes.controller;

import com.fieldnotes.dto.SiteDto;
import com.fieldnotes.model.User;
import com.fieldnotes.service.AuthService;
import com.fieldnotes.service.SiteService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/sites")
public class SiteController {

    private final SiteService siteService;
    private final AuthService authService;

    public SiteController(SiteService siteService, AuthService authService) {
        this.siteService = siteService;
        this.authService = authService;
    }

    @GetMapping
    public ResponseEntity<List<SiteDto>> getSites(
            @RequestParam(required = false) String customerId,
            @AuthenticationPrincipal UserDetails userDetails) {
        User user = authService.getCurrentUser(userDetails.getUsername());
        if (customerId != null && !customerId.isBlank()) {
            return ResponseEntity.ok(siteService.getSitesByCustomer(customerId, user.getId()));
        }
        return ResponseEntity.ok(siteService.getAllSites(user.getId()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<SiteDto> getSiteById(@PathVariable String id,
                                               @AuthenticationPrincipal UserDetails userDetails) {
        User user = authService.getCurrentUser(userDetails.getUsername());
        return ResponseEntity.ok(siteService.getSiteById(id, user.getId()));
    }

    @PostMapping
    public ResponseEntity<SiteDto> createSite(@Valid @RequestBody SiteDto dto,
                                              @AuthenticationPrincipal UserDetails userDetails) {
        User user = authService.getCurrentUser(userDetails.getUsername());
        return ResponseEntity.ok(siteService.createSite(dto, user));
    }

    @PutMapping("/{id}")
    public ResponseEntity<SiteDto> updateSite(@PathVariable String id,
                                              @Valid @RequestBody SiteDto dto,
                                              @AuthenticationPrincipal UserDetails userDetails) {
        User user = authService.getCurrentUser(userDetails.getUsername());
        return ResponseEntity.ok(siteService.updateSite(id, dto, user.getId()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSite(@PathVariable String id,
                                           @AuthenticationPrincipal UserDetails userDetails) {
        User user = authService.getCurrentUser(userDetails.getUsername());
        siteService.deleteSite(id, user.getId());
        return ResponseEntity.noContent().build();
    }
}
