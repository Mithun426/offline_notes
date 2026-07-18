import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/note/note_bloc.dart';
import '../blocs/note/note_event.dart';
import '../models/note.dart';
import '../blocs/note/note_state.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _bodyController  = TextEditingController(text: widget.note?.body  ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final body  = _bodyController.text.trim();
    if (title.isEmpty && body.isEmpty) return;
    if (widget.note == null) {
      context.read<NoteBloc>().add(AddNote(title, body));
    } else {
      context.read<NoteBloc>().add(UpdateNote(widget.note!.id, title, body));
    }
  }

  Future<void> _deleteNote() async {
    final cs = Theme.of(context).colorScheme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note?'),
        content: const Text('Are you sure you want to delete this note? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<NoteBloc>().add(DeleteNote(widget.note!.id));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.note == null ? 'New Note' : 'Edit Note',
          style: tt.titleLarge,
        ),
        actions: [
          if (widget.note != null)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: cs.error, size: 22),
              onPressed: _deleteNote,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocListener<NoteBloc, NoteState>(
        listener: (context, state) {
          if (state is NoteSavedSuccessfully) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Note saved successfully', style: TextStyle(fontWeight: FontWeight.w600)),
                backgroundColor: Colors.green.shade800,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
            Navigator.pop(context);
          } else if (state is NoteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save: ${state.message}', style: const TextStyle(fontWeight: FontWeight.w600)),
                backgroundColor: Colors.red.shade800,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
            Navigator.pop(context);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _titleController,
                  style: tt.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: 'Note Title',
                    hintStyle: tt.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface.withAlpha(100),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: InputBorder.none,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _bodyController,
                  style: tt.bodyLarge?.copyWith(color: cs.onSurface.withAlpha(200), height: 1.6),
                  decoration: InputDecoration(
                    hintText: 'Type your note details here...',
                    hintStyle: tt.bodyLarge?.copyWith(color: cs.onSurface.withAlpha(100), height: 1.6),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: InputBorder.none,
                  ),
                  minLines: 5,
                  maxLines: 5,
                  textAlignVertical: TextAlignVertical.top,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(height: 32),
              BlocBuilder<NoteBloc, NoteState>(
                builder: (context, state) {
                  final isSaving = state is NoteSaving;
                  return ElevatedButton(
                    onPressed: isSaving ? null : _saveNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      disabledBackgroundColor: cs.primary.withAlpha(128),
                    ),
                    child: isSaving
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 3, color: cs.onPrimary),
                          )
                        : const Text(
                            'Save Note',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
