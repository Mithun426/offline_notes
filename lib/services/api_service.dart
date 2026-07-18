import 'package:dio/dio.dart';
import '../models/note.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://6a5b412564f700df5bd6a976.mockapi.io/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<Note>> fetchNotes() async {
    try {
      final response = await _dio.get('/notes');
      final data = response.data as List;
      return data.map((e) => Note.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    }
  }

  Future<Note?> getNote(String id) async {
      try {
          final response = await _dio.get('/notes/$id');
          return Note.fromJson(response.data);
      } catch (e) {
          if (e is DioException && e.response?.statusCode == 404) {
              return null; // Not found on server
          }
          throw Exception('Failed to fetch note: $e');
      }
  }

  Future<void> createNote(Note note) async {
    try {
      await _dio.post('/notes', data: note.toJson());
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      await _dio.put('/notes/${note.id}', data: note.toJson());
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _dio.delete('/notes/$id');
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        // Already deleted on server
        return;
      }
      throw Exception('Failed to delete note: $e');
    }
  }
}
