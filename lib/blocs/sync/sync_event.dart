import 'package:equatable/equatable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

class StartSync extends SyncEvent {}

class SyncNoteProgress extends SyncEvent {
  final String noteId;

  const SyncNoteProgress(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

class ConnectivityChanged extends SyncEvent {
  final List<ConnectivityResult> result;

  const ConnectivityChanged(this.result);

  @override
  List<Object?> get props => [result];
}
