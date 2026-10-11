import 'dart:io';
import '../constants/api_constants.dart';
import '../network/api_client.dart';
import 'storage_service.dart';
import '../../models/sync_data.dart';
import '../../models/field_note_model.dart';

class SyncOutcome {
  final bool success;
  final int pushedCount;
  final int pulledCount;
  final String message;

  SyncOutcome({
    required this.success,
    this.pushedCount = 0,
    this.pulledCount = 0,
    required this.message,
  });
}

class SyncService {
  final ApiClient apiClient;
  final StorageService storageService;

  SyncService(this.apiClient, this.storageService);

  Future<SyncOutcome> synchronize() async {
    final token = storageService.getToken();
    if (token == null || token.isEmpty) {
      return SyncOutcome(
        success: false,
        message: 'User is not logged in. Cannot synchronize.',
      );
    }

    int totalPushed = 0;
    int totalPulled = 0;

    try {
      // 1. PUSH PHASE: Collect local unsynced changes
      final unsyncedCustomers = storageService.getUnsyncedCustomers();
      final unsyncedSites = storageService.getUnsyncedSites();
      final unsyncedNotes = storageService.getUnsyncedNotes();

      // Check if any notes need photo uploads first
      final processedNotes = <FieldNoteModel>[];
      for (var note in unsyncedNotes) {
        var currentNote = note;
        if (currentNote.localPhotoPath != null &&
            currentNote.localPhotoPath!.isNotEmpty &&
            (currentNote.photoUrl == null || currentNote.photoUrl!.isEmpty)) {
          final file = File(currentNote.localPhotoPath!);
          if (await file.exists()) {
            try {
              final remoteUrl = await apiClient.uploadPhoto(currentNote.localPhotoPath!);
              currentNote = currentNote.copyWith(photoUrl: remoteUrl);
              await storageService.saveNote(currentNote);
            } catch (_) {
              // If photo upload fails, still sync the note text; photo will retry next sync
            }
          }
        }
        processedNotes.add(currentNote);
      }

      if (unsyncedCustomers.isNotEmpty || unsyncedSites.isNotEmpty || processedNotes.isNotEmpty) {
        final pushBody = {
          'customers': unsyncedCustomers.map((c) => c.toJson()).toList(),
          'sites': unsyncedSites.map((s) => s.toJson()).toList(),
          'notes': processedNotes.map((n) => n.toJson()).toList(),
        };

        final response = await apiClient.post(ApiConstants.endpointSyncPush, body: pushBody);
        if (response != null && response is Map<String, dynamic>) {
          final pushResult = SyncPushResult.fromJson(response);
          if (pushResult.success) {
            // Mark pushed customers as synced
            for (var id in pushResult.syncedCustomerIds) {
              final c = storageService.getCustomerById(id);
              if (c != null) {
                await storageService.saveCustomer(c.copyWith(isSynced: true));
              }
            }
            // Mark pushed sites as synced
            for (var id in pushResult.syncedSiteIds) {
              final s = storageService.getSiteById(id);
              if (s != null) {
                await storageService.saveSite(s.copyWith(isSynced: true));
              }
            }
            // Mark pushed notes as synced
            for (var id in pushResult.syncedNoteIds) {
              final n = storageService.getNoteById(id);
              if (n != null) {
                await storageService.saveNote(n.copyWith(isSynced: true));
              }
            }
            totalPushed = pushResult.syncedCustomerIds.length +
                pushResult.syncedSiteIds.length +
                pushResult.syncedNoteIds.length;
          }
        }
      }

      // 2. PULL PHASE: Retrieve changes from server
      final lastSync = storageService.getLastSyncTime();
      final queryParams = <String, dynamic>{};
      if (lastSync != null) {
        queryParams['sinceEpoch'] = lastSync.millisecondsSinceEpoch.toString();
      }

      final pullResponse = await apiClient.get(
        ApiConstants.endpointSyncPull,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (pullResponse != null && pullResponse is Map<String, dynamic>) {
        final pullData = SyncPullData.fromJson(pullResponse);

        // Merge customers
        for (var remoteCustomer in pullData.customers) {
          final localCustomer = storageService.getCustomerById(remoteCustomer.id);
          if (localCustomer == null || localCustomer.isSynced) {
            await storageService.saveCustomer(remoteCustomer.copyWith(isSynced: true));
            totalPulled++;
          }
        }

        // Merge sites
        for (var remoteSite in pullData.sites) {
          final localSite = storageService.getSiteById(remoteSite.id);
          if (localSite == null || localSite.isSynced) {
            await storageService.saveSite(remoteSite.copyWith(isSynced: true));
            totalPulled++;
          }
        }

        // Merge notes
        for (var remoteNote in pullData.notes) {
          final localNote = storageService.getNoteById(remoteNote.id);
          if (localNote == null || localNote.isSynced) {
            // Preserve local photo path if present
            final mergedNote = remoteNote.copyWith(
              localPhotoPath: localNote?.localPhotoPath,
              isSynced: true,
            );
            await storageService.saveNote(mergedNote);
            totalPulled++;
          }
        }

        // Update last sync time
        await storageService.saveLastSyncTime(pullData.serverTime);
      }

      return SyncOutcome(
        success: true,
        pushedCount: totalPushed,
        pulledCount: totalPulled,
        message: 'Synchronization completed successfully.',
      );
    } catch (e) {
      return SyncOutcome(
        success: false,
        message: 'Sync failed: $e',
      );
    }
  }
}
