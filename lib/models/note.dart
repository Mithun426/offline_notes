import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'note.g.dart';

enum SyncStatus {
  synced,
  pendingSync,
  conflict,
}

class SyncStatusAdapter extends TypeAdapter<SyncStatus> {
  @override
  final int typeId = 1;

  @override
  SyncStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SyncStatus.synced;
      case 1:
        return SyncStatus.pendingSync;
      case 2:
        return SyncStatus.conflict;
      default:
        return SyncStatus.pendingSync;
    }
  }

  @override
  void write(BinaryWriter writer, SyncStatus obj) {
    switch (obj) {
      case SyncStatus.synced:
        writer.writeByte(0);
        break;
      case SyncStatus.pendingSync:
        writer.writeByte(1);
        break;
      case SyncStatus.conflict:
        writer.writeByte(2);
        break;
    }
  }
}

@HiveType(typeId: 0)
class Note extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final DateTime updatedAt;

  @HiveField(4)
  final SyncStatus syncStatus;
  
  @HiveField(5)
  final bool isDeleted; // Soft delete flag

  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pendingSync,
    this.isDeleted = false,
  });

  Note copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    bool? isDeleted,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    // MockAPI uses 'isUpdatedAt', fallback to 'updatedAt' for compatibility
    final updatedAtStr = json['isUpdatedAt'] as String? ?? json['updatedAt'] as String?;
    return Note(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      updatedAt: updatedAtStr != null ? DateTime.parse(updatedAtStr) : DateTime.now(),
      syncStatus: SyncStatus.synced,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'isUpdatedAt': updatedAt.toIso8601String(), // MockAPI field name
      'isDeleted': isDeleted,
    };
  }

  @override
  List<Object?> get props => [id, title, body, updatedAt, syncStatus, isDeleted];
}
