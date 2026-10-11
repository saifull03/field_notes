import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/sync_service.dart';
import '../../models/site_model.dart';
import 'site_event.dart';
import 'site_state.dart';

class SiteBloc extends Bloc<SiteEvent, SiteState> {
  final StorageService storageService;
  final SyncService syncService;
  final _uuid = const Uuid();

  SiteBloc({
    required this.storageService,
    required this.syncService,
  }) : super(SiteInitial()) {
    on<LoadSitesEvent>(_onLoadSites);
    on<AddSiteEvent>(_onAddSite);
    on<UpdateSiteEvent>(_onUpdateSite);
    on<DeleteSiteEvent>(_onDeleteSite);
  }

  void _onLoadSites(LoadSitesEvent event, Emitter<SiteState> emit) {
    emit(SiteLoading());
    try {
      final sites = event.customerId != null && event.customerId!.isNotEmpty
          ? storageService.getSitesByCustomerId(event.customerId!)
          : storageService.getAllSites();
      emit(SiteLoaded(sites));
    } catch (e) {
      emit(SiteError(e.toString()));
    }
  }

  Future<void> _onAddSite(AddSiteEvent event, Emitter<SiteState> emit) async {
    try {
      final customer = storageService.getCustomerById(event.customerId);
      final newSite = SiteModel(
        id: _uuid.v4(),
        customerId: event.customerId,
        customerName: customer?.name,
        name: event.name.trim(),
        address: event.address?.trim(),
        isSynced: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await storageService.saveSite(newSite);
      emit(const SiteOperationSuccess('Site created successfully'));

      // Reload list
      final sites = storageService.getAllSites();
      emit(SiteLoaded(sites));

      // Trigger background sync
      syncService.synchronize();
    } catch (e) {
      emit(SiteError(e.toString()));
    }
  }

  Future<void> _onUpdateSite(UpdateSiteEvent event, Emitter<SiteState> emit) async {
    try {
      final customer = storageService.getCustomerById(event.site.customerId);
      final updated = event.site.copyWith(
        customerName: customer?.name,
        isSynced: false,
        updatedAt: DateTime.now(),
      );

      await storageService.saveSite(updated);
      emit(const SiteOperationSuccess('Site updated successfully'));

      // Reload list
      final sites = storageService.getAllSites();
      emit(SiteLoaded(sites));

      // Trigger background sync
      syncService.synchronize();
    } catch (e) {
      emit(SiteError(e.toString()));
    }
  }

  Future<void> _onDeleteSite(DeleteSiteEvent event, Emitter<SiteState> emit) async {
    try {
      await storageService.deleteSite(event.siteId);
      emit(const SiteOperationSuccess('Site deleted successfully'));

      // Reload list
      final sites = storageService.getAllSites();
      emit(SiteLoaded(sites));

      // Trigger background sync
      syncService.synchronize();
    } catch (e) {
      emit(SiteError(e.toString()));
    }
  }
}
