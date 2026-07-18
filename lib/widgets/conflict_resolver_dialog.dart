import 'package:flutter/material.dart';
import '../models/note.dart';
import '../repositories/note_repository.dart';

class ConflictResolverDialog extends StatefulWidget {
  final Note localNote;
  final NoteRepository repository;
  final VoidCallback onResolved;

  const ConflictResolverDialog({
    super.key,
    required this.localNote,
    required this.repository,
    required this.onResolved,
  });

  @override
  State<ConflictResolverDialog> createState() => _ConflictResolverDialogState();
}

class _ConflictResolverDialogState extends State<ConflictResolverDialog> {
  bool _isLoading = false;

  void _resolve(bool keepLocal) async {
    setState(() {
      _isLoading = true;
    });

    await widget.repository.resolveConflict(widget.localNote.id, keepLocal);

    widget.onResolved();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sync Conflict Detected'),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This note was modified on the server and locally. Which version would you like to keep?',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Local Version:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(widget.localNote.title),
                Text(
                  widget.localNote.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                const Text(
                  'server:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('(Will overwrite local changes)'),
              ],
            ),
      actions: _isLoading
          ? []
          : [
              TextButton(
                onPressed: () => _resolve(true),
                child: const Text('Keep Local'),
              ),
              ElevatedButton(
                onPressed: () => _resolve(false),
                child: const Text('Keep Remote'),
              ),
            ],
    );
  }
}
