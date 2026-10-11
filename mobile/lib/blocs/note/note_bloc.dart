import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/sync_service.dart';
import 'note_event.dart';
import 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final StorageService storageService;
  final SyncService syncService;

  String? _currentQuery;
  String? _currentStatus;
  String? _currentSiteId;
  String? _currentCustomerId;

  NoteBloc({
    required this.storageService,
    required this.syncService,
  }) : super(NoteInitial()) {
    on<LoadNotesEvent>(_onLoadNotes);
    on<SearchAndFilterNotesEvent>(_onSearchAndFilterNotes);
    on<AddNoteEvent>(_onAddNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
  }

  void _onLoadNotes(LoadNotesEvent event, Emitter<NoteState> emit) {
    emit(NoteLoading());
    _currentQuery = event.query;
    _currentStatus = event.status;
    _currentSiteId = event.siteId;
    _currentCustomerId = event.customerId;

    try {
      final notes = storageService.searchAndFilterNotes(
        query: _currentQuery,
        status: _currentStatus,
        siteId: _currentSiteId,
        customerId: _currentCustomerId,
      );
      emit(NoteLoaded(
        notes: notes,
        activeQuery: _currentQuery,
        activeStatus: _currentStatus,
        activeSiteId: _currentSiteId,
        activeCustomerId: _currentCustomerId,
      ));
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  void _onSearchAndFilterNotes(SearchAndFilterNotesEvent event, Emitter<NoteState> emit) {
    _currentQuery = event.query;
    _currentStatus = event.status;
    _currentSiteId = event.siteId;
    _currentCustomerId = event.customerId;

    try {
      final notes = storageService.searchAndFilterNotes(
        query: _currentQuery,
        status: _currentStatus,
        siteId: _currentSiteId,
        customerId: _currentCustomerId,
      );
      emit(NoteLoaded(
        notes: notes,
        activeQuery: _currentQuery,
        activeStatus: _currentStatus,
        activeSiteId: _currentSiteId,
        activeCustomerId: _currentCustomerId,
      ));
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  Future<void> _onAddNote(AddNoteEvent event, Emitter<NoteState> emit) async {
    try {
      final site = storageService.getSiteById(event.note.siteId);
      final customer = site != null ? storageService.getCustomerById(site.customerId) : null;

      final preparedNote = event.note.copyWith(
        siteName: site?.name,
        customerId: customer?.id,
        customerName: customer?.name,
        isSynced: false,
        updatedAt: DateTime.now(),
      );

      await storageService.saveNote(preparedNote);
      emit(const NoteOperationSuccess('Field note saved successfully'));

      // Reload list
      final notes = storageService.searchAndFilterNotes(
        query: _currentQuery,
        status: _currentStatus,
        siteId: _currentSiteId,
        customerId: _currentCustomerId,
      );
      emit(NoteLoaded(
        notes: notes,
        activeQuery: _currentQuery,
        activeStatus: _currentStatus,
        activeSiteId: _currentSiteId,
        activeCustomerId: _currentCustomerId,
      ));

      // Trigger background sync
      syncService.synchronize();
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  Future<void> _onUpdateNote(UpdateNoteEvent event, Emitter<NoteState> emit) async {
    try {
      final site = storageService.getSiteById(event.note.siteId);
      final customer = site != null ? storageService.getCustomerById(site.customerId) : null;

      final updated = event.note.copyWith(
        siteName: site?.name,
        customerId: customer?.id,
        customerName: customer?.name,
        isSynced: false,
        updatedAt: DateTime.now(),
      );

      await storageService.saveNote(updated);
      emit(const NoteOperationSuccess('Field note updated successfully'));

      // Reload list
      final notes = storageService.searchAndFilterNotes(
        query: _currentQuery,
        status: _currentStatus,
        siteId: _currentSiteId,
        customerId: _currentCustomerId,
      );
      emit(NoteLoaded(
        notes: notes,
        activeQuery: _currentQuery,
        activeStatus: _currentStatus,
        activeSiteId: _currentSiteId,
        activeCustomerId: _currentCustomerId,
      ));

      // Trigger background sync
      syncService.synchronize();
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  Future<void> _onDeleteNote(DeleteNoteEvent event, Emitter<NoteState> emit) async {
    try {
      await storageService.deleteNote(event.noteId);
      emit(const NoteOperationSuccess('Field note deleted successfully'));

      // Reload list
      final notes = storageService.searchAndFilterNotes(
        query: _currentQuery,
        status: _currentStatus,
        siteId: _currentSiteId,
        customerId: _currentCustomerId,
      );
      emit(NoteLoaded(
        notes: notes,
        activeQuery: _currentQuery,
        activeStatus: _currentStatus,
        activeSiteId: _currentSiteId,
        activeCustomerId: _currentCustomerId,
      ));

      // Trigger background sync
      syncService.synchronize();
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }
}
