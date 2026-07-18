import 'package:equatable/equatable.dart';

abstract class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

class SyncInitial extends SyncState {}

class SyncInProgress extends SyncState {
  final String? syncingNoteId;

  const SyncInProgress({this.syncingNoteId});

  @override
  List<Object?> get props => [syncingNoteId];
}

class SyncSuccess extends SyncState {}

class SyncFailure extends SyncState {
  final String error;

  const SyncFailure(this.error);

  @override
  List<Object?> get props => [error];
}
