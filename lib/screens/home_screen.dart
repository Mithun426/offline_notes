import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../blocs/note/note_bloc.dart';
import '../blocs/note/note_event.dart';
import '../blocs/note/note_state.dart';
import '../blocs/sync/sync_bloc.dart';
import '../blocs/sync/sync_state.dart';
import '../models/note.dart';
import '../repositories/note_repository.dart';
import '../widgets/conflict_resolver_dialog.dart';
import 'note_editor_screen.dart';

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
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      result,
    ) {
      final isOffline = result.contains(ConnectivityResult.none);
      if (isOffline) {
        _wasOffline = true;
        _showToast(
          '📡  You are offline. Changes saved locally.',
          Colors.orange.shade800,
        );
      } else if (_wasOffline) {
        _wasOffline = false;
        _showToast('✅  Back online! Syncing changes...', Colors.green.shade800);
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _showToast(String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: BlocListener<SyncBloc, SyncState>(
        listener: (context, state) {
          if (state is SyncSuccess) context.read<NoteBloc>().add(LoadNotes());
        },
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, cs, tt),
              Expanded(child: _buildAllNotesTab(cs, tt)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }


  Widget _buildAppBar(BuildContext context, ColorScheme cs, TextTheme tt) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 16, 8),
      child: Row(
        children: [
          Text('Notes', style: tt.headlineLarge),
          const Spacer(),
          BlocBuilder<SyncBloc, SyncState>(
            builder: (context, state) => _syncChip(state, cs),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _syncChip(SyncState state, ColorScheme cs) {
    if (state is SyncInProgress) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 6),
            Text('Syncing', style: TextStyle(color: cs.primary, fontSize: 11)),
          ],
        ),
      );
    }
    if (state is SyncSuccess)
      return _chip(Icons.cloud_done, 'Synced', Colors.greenAccent, cs);
    if (state is SyncFailure)
      return _chip(Icons.cloud_off, 'Offline', Colors.orangeAccent, cs);
    return _chip(Icons.cloud_queue, 'Ready', cs.onSurface.withAlpha(153), cs);
  }

  Widget _chip(IconData icon, String label, Color color, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }


  Widget _buildAllNotesTab(ColorScheme cs, TextTheme tt) {
    return BlocBuilder<NoteBloc, NoteState>(
      buildWhen: (previous, current) {
        return current is NoteLoading ||
            current is NoteLoaded ||
            current is NoteError;
      },
      builder: (context, state) {
        if (state is NoteLoading)
          return Center(child: CircularProgressIndicator(color: cs.primary));
        if (state is NoteError)
          return Center(
            child: Text(
              'Error: ${state.message}',
              style: TextStyle(color: cs.error),
            ),
          );
        if (state is NoteLoaded) {
          if (state.notes.isEmpty) return _buildEmptyState(cs, tt);
          return _buildMasonryGrid(state.notes, cs, tt);
        }
        return const SizedBox();
      },
    );
  }


  Widget _buildMasonryGrid(List<Note> notes, ColorScheme cs, TextTheme tt) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return _buildNoteCard(notes[index], cs, tt);
      },
    );
  }

  Widget _buildNoteCard(Note note, ColorScheme cs, TextTheme tt) {
    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: cs.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) => _showDeletionDialog(context, note),
      onDismissed: (_) => context.read<NoteBloc>().add(LoadNotes()),
      child: GestureDetector(
        onTap: () {
          if (note.syncStatus == SyncStatus.conflict) {
            _showConflictDialog(context, note);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: note.syncStatus == SyncStatus.conflict
                  ? cs.error.withAlpha(128)
                  : cs.surface,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    BlocBuilder<SyncBloc, SyncState>(
                      builder: (context, syncState) {
                        if (syncState is SyncInProgress &&
                            syncState.syncingNoteId == note.id) {
                          return SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.primary,
                            ),
                          );
                        }
                        return _syncDot(note.syncStatus, cs);
                      },
                    ),
                    const Spacer(),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        final delete = await _showDeletionDialog(context, note);
                        if (delete == true && context.mounted) {
                          context.read<NoteBloc>().add(LoadNotes());
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: cs.onSurface.withAlpha(153),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (note.title.isNotEmpty)
                  Text(
                    note.title,
                    style: tt.titleMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                if (note.body.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    note.body,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodyMedium,
                  ),
                ],
                const SizedBox(height: 10),

                Row(
                  children: [
                    Icon(Icons.schedule, size: 10),
                    SizedBox(width: 5),
                    Text(_formatDate(note.updatedAt), style: tt.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _syncDot(SyncStatus status, ColorScheme cs) {
    Color color;
    String label;
    switch (status) {
      case SyncStatus.synced:
        color = Colors.greenAccent;
        label = 'Synced';
        break;
      case SyncStatus.pendingSync:
        color = cs.primary;
        label = 'Pending';
        break;
      case SyncStatus.conflict:
        color = cs.error;
        label = 'Conflict';
        break;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }


  Widget _buildEmptyState(ColorScheme cs, TextTheme tt) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: cs.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.note_add_outlined, size: 56, color: cs.primary),
          ),
          const SizedBox(height: 24),
          Text('No Notes Yet', style: tt.headlineLarge?.copyWith(fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first note.\nWorks offline too!',
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }


  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showConflictDialog(BuildContext context, Note localNote) {
    showDialog(
      context: context,
      builder: (_) => ConflictResolverDialog(
        localNote: localNote,
        repository: context.read<NoteRepository>(),
        onResolved: () => context.read<NoteBloc>().add(LoadNotes()),
      ),
    );
  }

  Future<bool?> _showDeletionDialog(BuildContext context, Note note) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Delete Note?'),
              content: const Text(
                'Are you sure you want to delete this note? This action cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setState(() => isDeleting = true);
                          await context.read<NoteRepository>().deleteNote(note.id);
                          if (context.mounted) {
                            Navigator.pop(context, true);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.error,
                    foregroundColor: cs.onError,
                  ),
                  child: isDeleting
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.onError,
                          ),
                        )
                      : const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
