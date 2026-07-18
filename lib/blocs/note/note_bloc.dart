import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/note_repository.dart';
import 'note_event.dart';
import 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteRepository _repository;

  NoteBloc(this._repository) : super(NoteInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
  }

  void _onLoadNotes(LoadNotes event, Emitter<NoteState> emit) {
    emit(NoteLoading());
    try {
      final notes = _repository.getNotes();
      emit(NoteLoaded(notes));
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  Future<void> _onAddNote(AddNote event, Emitter<NoteState> emit) async {
    try {
      await _repository.addNote(event.title, event.body);
      add(LoadNotes()); // Reload to reflect changes
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  Future<void> _onUpdateNote(UpdateNote event, Emitter<NoteState> emit) async {
    try {
      await _repository.updateNote(event.id, event.title, event.body);
      add(LoadNotes());
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NoteState> emit) async {
    try {
      await _repository.deleteNote(event.id);
      add(LoadNotes());
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }
}
