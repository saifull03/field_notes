package com.fieldnotes.controller;

import com.fieldnotes.dto.SyncPullResponse;
import com.fieldnotes.dto.SyncPushRequest;
import com.fieldnotes.dto.SyncPushResponse;
import com.fieldnotes.model.User;
import com.fieldnotes.service.AuthService;
import com.fieldnotes.service.SyncService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;

@RestController
@RequestMapping("/api/sync")
public class SyncController {

    private final SyncService syncService;
    private final AuthService authService;

    public SyncController(SyncService syncService, AuthService authService) {
        this.syncService = syncService;
        this.authService = authService;
    }

    @GetMapping("/pull")
    public ResponseEntity<SyncPullResponse> pull(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant since,
            @RequestParam(required = false) Long sinceEpoch,
            @AuthenticationPrincipal UserDetails userDetails) {
        User user = authService.getCurrentUser(userDetails.getUsername());

        Instant sinceInstant = since;
        if (sinceInstant == null && sinceEpoch != null && sinceEpoch > 0) {
            sinceInstant = Instant.ofEpochMilli(sinceEpoch);
        }

        return ResponseEntity.ok(syncService.pullSync(user, sinceInstant));
    }

    @PostMapping("/push")
    public ResponseEntity<SyncPushResponse> push(
            @RequestBody SyncPushRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        User user = authService.getCurrentUser(userDetails.getUsername());
        return ResponseEntity.ok(syncService.pushSync(user, request));
    }
}
