import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';

class NoteRepository {
  final HiveService _hiveService;
  final ApiService _apiService;
  final Connectivity _connectivity;
  final _uuid = const Uuid();

  NoteRepository(this._hiveService, this._apiService, this._connectivity);

  List<Note> getNotes() {
    return _hiveService.getNotes();
  }

  Future<void> addNote(String title, String body) async {
    final note = Note(
      id: _uuid.v4(),
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingSync,
    );
    await _hiveService.saveNote(note);
    await syncNotes(); // Try to sync immediately
  }

  Future<void> updateNote(String id, String title, String body) async {
    final existingNote = _hiveService.getNote(id);
    if (existingNote == null) return;

    final updatedNote = existingNote.copyWith(
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingSync,
    );
    await _hiveService.saveNote(updatedNote);
    await syncNotes(); // Try to sync immediately
  }

  Future<void> deleteNote(String id) async {
    await _hiveService.deleteNoteLocally(id);
    await syncNotes(); // Try to sync immediately
  }

  Future<void> resolveConflict(String noteId, bool keepLocal) async {
    final localNote = _hiveService.getNote(noteId);
    if (localNote == null) return;

    if (keepLocal) {
      // Mark as pending sync to force push to server
      final updatedNote = localNote.copyWith(
          syncStatus: SyncStatus.pendingSync,
          updatedAt: DateTime.now()
      );
      await _hiveService.saveNote(updatedNote);
      await syncNotes();
    } else {
      // Fetch remote and overwrite local
      final remoteNote = await _apiService.getNote(noteId);
      if (remoteNote != null) {
          final updatedNote = remoteNote.copyWith(syncStatus: SyncStatus.synced);
          await _hiveService.saveNote(updatedNote);
      } else {
          // If deleted on server
          await _hiveService.removeNotePermanently(noteId);
      }
    }
  }

  Future<void> syncNotes({void Function(String noteId)? onNoteSyncing}) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
        return; // Offline, can't sync
    }

    try {
      // 1. Push pending local changes to server
      final pendingNotes = _hiveService.getPendingSyncNotes();
      for (var localNote in pendingNotes) {
        try {
            onNoteSyncing?.call(localNote.id);
            // Add a small artificial delay so the user can see the "syncing" animation
            await Future.delayed(const Duration(milliseconds: 800));
            
            final remoteNote = await _apiService.getNote(localNote.id);

            if (remoteNote != null && remoteNote.updatedAt.isAfter(localNote.updatedAt)) {
                // Server has a newer version, mark as conflict
                await _hiveService.saveNote(localNote.copyWith(syncStatus: SyncStatus.conflict));
                continue; // Skip pushing
            }

            if (localNote.isDeleted) {
                await _apiService.deleteNote(localNote.id);
                await _hiveService.removeNotePermanently(localNote.id);
            } else {
                if (remoteNote == null) {
                    await _apiService.createNote(localNote);
                } else {
                    await _apiService.updateNote(localNote);
                }
                // Mark as synced locally
                await _hiveService.saveNote(localNote.copyWith(syncStatus: SyncStatus.synced));
            }
        } catch (e) {
            print('Failed to sync note ${localNote.id}: $e');
        }
      }

      // 2. Fetch all from server to update local database
      final serverNotes = await _apiService.fetchNotes();
      for (var remoteNote in serverNotes) {
        final localNote = _hiveService.getNote(remoteNote.id);
        
        if (localNote == null) {
             // New note from server
             await _hiveService.saveNote(remoteNote.copyWith(syncStatus: SyncStatus.synced));
        } else if (localNote.syncStatus == SyncStatus.synced || localNote.syncStatus == SyncStatus.conflict) {
             if (remoteNote.updatedAt.isAfter(localNote.updatedAt)) {
                // Update local version if server is newer and we don't have pending changes
                await _hiveService.saveNote(remoteNote.copyWith(syncStatus: SyncStatus.synced));
             }
        }
      }
    } catch (e) {
      print('Sync failed: $e');
    }
  }
}
