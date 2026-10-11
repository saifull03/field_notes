import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/sync_service.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncService syncService;
  final StorageService storageService;

  SyncBloc({
    required this.syncService,
    required this.storageService,
  }) : super(SyncInitial(
          lastSyncTime: storageService.getLastSyncTime(),
          unsyncedCount: _calcUnsynced(storageService),
        )) {
    on<TriggerSyncEvent>(_onTriggerSync);
    on<CheckSyncStatusEvent>(_onCheckSyncStatus);
  }

  static int _calcUnsynced(StorageService storage) {
    return storage.getUnsyncedCustomers().length +
        storage.getUnsyncedSites().length +
        storage.getUnsyncedNotes().length;
  }

  void _onCheckSyncStatus(CheckSyncStatusEvent event, Emitter<SyncState> emit) {
    emit(SyncInitial(
      lastSyncTime: storageService.getLastSyncTime(),
      unsyncedCount: _calcUnsynced(storageService),
    ));
  }

  Future<void> _onTriggerSync(TriggerSyncEvent event, Emitter<SyncState> emit) async {
    emit(SyncInProgress());
    final outcome = await syncService.synchronize();

    final lastSync = storageService.getLastSyncTime() ?? DateTime.now();
    final remainingUnsynced = _calcUnsynced(storageService);

    if (outcome.success) {
      emit(SyncSuccess(
        message: outcome.message,
        pushedCount: outcome.pushedCount,
        pulledCount: outcome.pulledCount,
        lastSyncTime: lastSync,
        unsyncedCount: remainingUnsynced,
      ));
    } else {
      emit(SyncFailure(
        message: outcome.message,
        lastSyncTime: storageService.getLastSyncTime(),
        unsyncedCount: remainingUnsynced,
      ));
    }
  }
}

