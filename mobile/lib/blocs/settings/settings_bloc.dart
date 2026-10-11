import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/storage_service.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final StorageService storageService;

  SettingsBloc({required this.storageService}) : super(SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<UpdateDefaultNoteStatusEvent>(_onUpdateDefaultNoteStatus);
    on<UpdateBaseUrlEvent>(_onUpdateBaseUrl);
  }

  void _onLoadSettings(LoadSettingsEvent event, Emitter<SettingsState> emit) {
    final status = storageService.getDefaultNoteStatus();
    final url = storageService.getBaseUrl();
    emit(SettingsLoaded(defaultNoteStatus: status, baseUrl: url));
  }

  Future<void> _onUpdateDefaultNoteStatus(UpdateDefaultNoteStatusEvent event, Emitter<SettingsState> emit) async {
    await storageService.saveDefaultNoteStatus(event.status);
    final url = storageService.getBaseUrl();
    emit(SettingsLoaded(defaultNoteStatus: event.status, baseUrl: url));
  }

  Future<void> _onUpdateBaseUrl(UpdateBaseUrlEvent event, Emitter<SettingsState> emit) async {
    await storageService.saveBaseUrl(event.baseUrl.trim());
    final status = storageService.getDefaultNoteStatus();
    emit(SettingsLoaded(defaultNoteStatus: status, baseUrl: event.baseUrl.trim()));
  }
}

