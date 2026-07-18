import 'package:equatable/equatable.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotes extends NoteEvent {}

class AddNote extends NoteEvent {
  final String title;
  final String body;

  const AddNote(this.title, this.body);

  @override
  List<Object?> get props => [title, body];
}

class UpdateNote extends NoteEvent {
  final String id;
  final String title;
  final String body;

  const UpdateNote(this.id, this.title, this.body);

  @override
  List<Object?> get props => [id, title, body];
}

class DeleteNote extends NoteEvent {
  final String id;

  const DeleteNote(this.id);

  @override
  List<Object?> get props => [id];
}
