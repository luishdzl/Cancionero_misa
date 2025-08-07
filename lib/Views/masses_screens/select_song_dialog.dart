import 'package:flutter/material.dart';
import 'package:sqlite_flutter_crud/SQLite/sqlite.dart';
import 'package:sqlite_flutter_crud/JsonModels/note_model.dart';

class SelectSongDialog extends StatefulWidget {
  const SelectSongDialog({super.key});

  @override
  State<SelectSongDialog> createState() => _SelectSongDialogState();
}

class _SelectSongDialogState extends State<SelectSongDialog> {
  final db = DatabaseHelper();
  late Future<List<NoteModel>> notes;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    notes = db.getNotes();
  }

  void _searchNotes(String keyword) {
    if (keyword.isEmpty) {
      setState(() => notes = db.getNotes());
    } else {
      setState(() => notes = db.searchNotes(keyword));
    }
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
                    return ListTile(
                      title: Text(note.noteTitle),
                      subtitle: Text('Tono: ${note.currentKey}'),
                      onTap: () => Navigator.pop(context, note),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}