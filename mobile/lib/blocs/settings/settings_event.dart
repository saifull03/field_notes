import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {}

class UpdateDefaultNoteStatusEvent extends SettingsEvent {
  final String status;

  const UpdateDefaultNoteStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class UpdateBaseUrlEvent extends SettingsEvent {
  final String baseUrl;

  const UpdateBaseUrlEvent(this.baseUrl);

  @override
  List<Object?> get props => [baseUrl];
}

