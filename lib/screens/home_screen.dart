import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/note/note_bloc.dart';
import '../blocs/note/note_event.dart';
import '../blocs/note/note_state.dart';
import '../blocs/sync/sync_bloc.dart';
import '../blocs/sync/sync_state.dart';
import '../models/note.dart';
import '../repositories/note_repository.dart';
import '../widgets/conflict_resolver_dialog.dart';
import 'note_editor_screen.dart';

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription? _connectivitySubscription;
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      final isOffline = result.contains(ConnectivityResult.none);
      
      if (isOffline) {
        _wasOffline = true;
        _showToast('You are offline. Changes will be saved locally.', Colors.orange);
      } else if (_wasOffline) {
        _wasOffline = false;
        _showToast('Back online! Syncing changes...', Colors.green);
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _showToast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline-First Notes'),
        actions: [
          BlocBuilder<SyncBloc, SyncState>(
            builder: (context, state) {
              if (state is SyncInProgress) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                );
              }
              if (state is SyncFailure) {
                return const Icon(Icons.cloud_off, color: Colors.red);
              }
              if (state is SyncSuccess) {
                return const Icon(Icons.cloud_done, color: Colors.green);
              }
              return const Icon(Icons.cloud_queue);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocListener<SyncBloc, SyncState>(
        listener: (context, state) {
          if (state is SyncSuccess) {
            context.read<NoteBloc>().add(LoadNotes());
          }
        },
        child: BlocBuilder<NoteBloc, NoteState>(
          builder: (context, state) {
            if (state is NoteLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is NoteError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is NoteLoaded) {
              final notes = state.notes;
              if (notes.isEmpty) {
                return const Center(child: Text('No notes yet. Create one!'));
              }
              return ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return Dismissible(
                    key: Key(note.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      context.read<NoteBloc>().add(DeleteNote(note.id));
                    },
                    child: ListTile(
                      title: Text(note.title),
                      subtitle: Text(
                        note.body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BlocBuilder<SyncBloc, SyncState>(
                            builder: (context, syncState) {
                              if (syncState is SyncInProgress && syncState.syncingNoteId == note.id) {
                                return const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                );
                              }
                              return _buildSyncIcon(note.syncStatus);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.grey),
                            onPressed: () {
                              context.read<NoteBloc>().add(DeleteNote(note.id));
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        if (note.syncStatus == SyncStatus.conflict) {
                          _showConflictDialog(context, note);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NoteEditorScreen(note: note),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              );
            }
            return const Center(child: Text('Unknown state'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NoteEditorScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSyncIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case SyncStatus.pendingSync:
        return const Icon(Icons.sync_problem, color: Colors.orange, size: 20);
      case SyncStatus.conflict:
        return const Icon(Icons.error, color: Colors.red, size: 20);
    }
  }

  void _showConflictDialog(BuildContext context, Note localNote) {
    showDialog(
      context: context,
      builder: (_) => ConflictResolverDialog(
        localNote: localNote,
        repository: context.read<NoteRepository>(),
        onResolved: () {
          context.read<NoteBloc>().add(LoadNotes());
        },
      ),
    );
  }
}
