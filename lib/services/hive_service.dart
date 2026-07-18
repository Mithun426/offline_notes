import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';

class HiveService {
  static const String notesBoxName = 'notes';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SyncStatusAdapter());
    Hive.registerAdapter(NoteAdapter());
    await Hive.openBox<Note>(notesBoxName);
  }

  Box<Note> get _box => Hive.box<Note>(notesBoxName);

  List<Note> getNotes() {
    return _box.values.where((note) => !note.isDeleted).toList();
  }

  List<Note> getPendingSyncNotes() {
    return _box.values.where((note) => note.syncStatus == SyncStatus.pendingSync).toList();
  }

  Note? getNote(String id) {
    return _box.get(id);
  }

  Future<void> saveNote(Note note) async {
    await _box.put(note.id, note);
  }

  Future<void> deleteNoteLocally(String id) async {
    final note = _box.get(id);
    if (note != null) {
      // Soft delete to let the server know it was deleted
      final deletedNote = note.copyWith(
        isDeleted: true,
        syncStatus: SyncStatus.pendingSync,
        updatedAt: DateTime.now(),
      );
      await _box.put(id, deletedNote);
    }
  }
  
  Future<void> removeNotePermanently(String id) async {
      await _box.delete(id);
  }

  Future<void> saveAll(List<Note> notes) async {
    final Map<String, Note> notesMap = {for (var e in notes) e.id: e};
    await _box.putAll(notesMap);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
