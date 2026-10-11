import 'package:equatable/equatable.dart';
import '../../models/field_note_model.dart';

abstract class NoteState extends Equatable {
  const NoteState();
  @override
  List<Object?> get props => [];
}

class NoteInitial extends NoteState {}

class NoteLoading extends NoteState {}

class NoteLoaded extends NoteState {
  final List<FieldNoteModel> notes;
  final String? activeQuery;
  final String? activeStatus;
  final String? activeSiteId;
  final String? activeCustomerId;

  const NoteLoaded({
    required this.notes,
    this.activeQuery,
    this.activeStatus,
    this.activeSiteId,
    this.activeCustomerId,
  });

  @override
  List<Object?> get props => [notes, activeQuery, activeStatus, activeSiteId, activeCustomerId];
}

class NoteOperationSuccess extends NoteState {
  final String message;

  const NoteOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class NoteError extends NoteState {
  final String message;

  const NoteError(this.message);

  @override
  List<Object?> get props => [message];
}

