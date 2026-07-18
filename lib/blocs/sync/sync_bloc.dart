import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/note_repository.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final NoteRepository _repository;
  final Connectivity _connectivity;
  StreamSubscription? _connectivitySubscription;

  SyncBloc(this._repository, this._connectivity) : super(SyncInitial()) {
    on<StartSync>(_onStartSync);
    on<ConnectivityChanged>(_onConnectivityChanged);

    on<SyncNoteProgress>(_onSyncNoteProgress);

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      add(ConnectivityChanged(result));
    });
  }

  Future<void> _onStartSync(StartSync event, Emitter<SyncState> emit) async {
    emit(const SyncInProgress());
    try {
      await _repository.syncNotes(
        onNoteSyncing: (noteId) {
          add(SyncNoteProgress(noteId));
        },
      );
      emit(SyncSuccess());
    } catch (e) {
      emit(SyncFailure(e.toString()));
    }
  }

  void _onSyncNoteProgress(SyncNoteProgress event, Emitter<SyncState> emit) {
    emit(SyncInProgress(syncingNoteId: event.noteId));
  }

  void _onConnectivityChanged(ConnectivityChanged event, Emitter<SyncState> emit) {
    if (!event.result.contains(ConnectivityResult.none)) {
      // Internet is back, start sync
      add(StartSync());
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
