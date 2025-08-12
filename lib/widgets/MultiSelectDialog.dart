import 'package:flutter/material.dart';
import 'package:sqlite_flutter_crud/JsonModels/note_model.dart';
import 'package:sqlite_flutter_crud/SQLite/sqlite.dart';

class MultiSelectDialog extends StatefulWidget {
  final List<NoteModel> selectedNotes;
  
  const MultiSelectDialog({super.key, required this.selectedNotes});

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  final db = DatabaseHelper();
  late Future<List<NoteModel>> notes;
  final searchController = TextEditingController();
  List<NoteModel> selectedNotes = [];

  @override
  void initState() {
    super.initState();
    notes = db.getNotes();
    selectedNotes = List.from(widget.selectedNotes);
  }

  void _searchNotes(String keyword) {
    if (keyword.isEmpty) {
      setState(() => notes = db.getNotes());
    } else {
      setState(() => notes = db.searchNotes(keyword));
    }
  }

  void _toggleSelection(NoteModel note) {
    setState(() {
      if (selectedNotes.any((n) => n.noteId == note.noteId)) {
        selectedNotes.removeWhere((n) => n.noteId == note.noteId);
      } else {
        selectedNotes.add(note);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Buscar canción',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _searchNotes('');
                  },
                ),
              ),
              onChanged: _searchNotes,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<NoteModel>>(
              future: notes,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final note = snapshot.data![index];
                    final isSelected = selectedNotes.any((n) => n.noteId == note.noteId);
                    
                    return CheckboxListTile(
                      title: Text(note.noteTitle),
                      subtitle: Text('Tono: ${note.currentKey}'),
                      value: isSelected,
                      onChanged: (_) => _toggleSelection(note),
                    );
                  },
                );
              },
            ),
          ),
          ButtonBar(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, selectedNotes),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}