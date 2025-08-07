import 'package:flutter/material.dart';
import 'package:sqlite_flutter_crud/JsonModels/note_model.dart';
import 'package:sqlite_flutter_crud/SQLite/sqlite.dart';
import 'package:sqlite_flutter_crud/utils/transpose.dart'; // Importamos las funciones de transposición
import 'edit_note.dart';

class NoteDetailScreen extends StatefulWidget {
  final NoteModel note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late NoteModel currentNote;
  late String displayedContent;
  final db = DatabaseHelper();

  // Variable para rastrear si la nota fue editada
  bool _edited = false;

  @override
  void initState() {
    super.initState();
    currentNote = widget.note;
    displayedContent = currentNote.noteContent;
  }

  void transposeContent(int semitones) {
    setState(() {
      // Utilizamos la función transposeText del archivo transpose.dart
      displayedContent = transposeText(displayedContent, semitones);
    });
  }

  void _transpose(int semitones) {
    final currentIndex = musicKeys.indexOf(currentNote.currentKey);
    int newIndex = currentIndex + semitones;
    if (newIndex < 0) newIndex += musicKeys.length;
    if (newIndex >= musicKeys.length) newIndex -= musicKeys.length;
    final newKey = musicKeys[newIndex];

    transposeContent(semitones);

    db.updateCurrentKey(currentNote.noteId!, newKey).then((_) {
      setState(() {
        currentNote = currentNote.copyWith(currentKey: newKey);
        _edited = true; // Marcar como editado
      });
    });
  }

  void _resetToOriginal() {
    final currentIndex = musicKeys.indexOf(currentNote.currentKey);
    final originalIndex = musicKeys.indexOf(currentNote.originalKey);
    final semitonesDifference = originalIndex - currentIndex;

    transposeContent(semitonesDifference);

    db.updateCurrentKey(currentNote.noteId!, currentNote.originalKey).then((_) {
      setState(() {
        currentNote = currentNote.copyWith(currentKey: currentNote.originalKey);
        _edited = true; // Marcar como editado
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Pasar el estado de edición al navegar hacia atrás
        Navigator.pop(context, _edited);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(currentNote.noteTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, _edited);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _navigateToEdit(context),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Tono actual: ${currentNote.currentKey}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Original: ${currentNote.originalKey}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    displayedContent,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_downward),
                onPressed: () => _transpose(-1),
                tooltip: 'Bajar semitono',
              ),
              IconButton(
                icon: const Icon(Icons.replay),
                onPressed: _resetToOriginal,
                tooltip: 'Tono original',
              ),
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed: () => _transpose(1),
                tooltip: 'Subir semitono',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) async {
    final shouldRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(note: currentNote),
      ),
    );

    if (shouldRefresh == true) {
      final updatedNote = await db.getNoteById(currentNote.noteId!);
      setState(() {
        currentNote = updatedNote;
        displayedContent = updatedNote.noteContent;
        _edited = true; // Marcar como editado
      });
    }
  }
}