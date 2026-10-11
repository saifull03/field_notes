import 'package:equatable/equatable.dart';
import '../../models/field_note_model.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotesEvent extends NoteEvent {
  final String? query;
  final String? status;
  final String? siteId;
  final String? customerId;

  const LoadNotesEvent({
    this.query,
    this.status,
    this.siteId,
    this.customerId,
  });

  @override
  List<Object?> get props => [query, status, siteId, customerId];
}

class SearchAndFilterNotesEvent extends NoteEvent {
  final String? query;
  final String? status;
  final String? siteId;
  final String? customerId;

  const SearchAndFilterNotesEvent({
    this.query,
    this.status,
    this.siteId,
    this.customerId,
  });

  @override
  List<Object?> get props => [query, status, siteId, customerId];
}

class AddNoteEvent extends NoteEvent {
  final FieldNoteModel note;

  const AddNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

class UpdateNoteEvent extends NoteEvent {
  final FieldNoteModel note;

  const UpdateNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

class DeleteNoteEvent extends NoteEvent {
  final String noteId;

  const DeleteNoteEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

