import 'package:flutter/material.dart';
import 'package:sqlite_flutter_crud/JsonModels/note_model.dart';
import 'package:sqlite_flutter_crud/SQLite/sqlite.dart';
import 'package:sqlite_flutter_crud/Views/notes_screens/create_note.dart';
import 'package:sqlite_flutter_crud/Views/notes_screens/note_detail.dart';

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  late DatabaseHelper handler;
  late Future<List<NoteModel>> notes;
  final db = DatabaseHelper();

  final keyword = TextEditingController();

  @override
  void initState() {
    handler = DatabaseHelper();
    notes = getAllNotes();
    super.initState();
  }

  Future<List<NoteModel>> getAllNotes() {
    return handler.getNotes();
  }

  Future<List<NoteModel>> searchNote() {
    return handler.searchNotes(keyword.text);
  }

  Future<void> _refresh() async {
    setState(() {
      notes = getAllNotes();
    });
  }

  void _deleteNote(NoteModel note) {
    db.deleteNote(note.noteId!).whenComplete(() => _refresh());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Partituras"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CreateNote()))
              .then((value) {
            if (value) {
              _refresh();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(.2),
                borderRadius: BorderRadius.circular(8)),
            child: TextFormField(
              controller: keyword,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    notes = searchNote();
                  });
                } else {
                  setState(() {
                    notes = getAllNotes();
                  });
                }
              },
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                  hintText: "Buscar partituras"),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<NoteModel>>(
              future: notes,
              builder: (BuildContext context,
                  AsyncSnapshot<List<NoteModel>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const Center(child: Text("No hay partituras"));
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else {
                  final items = snapshot.data ?? <NoteModel>[];
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(items[index].noteTitle),
                        subtitle: Text("Tono: ${items[index].currentKey}"),
                        onTap: () async {
                          // Esperar por posibles cambios
                          final shouldRefresh = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteDetailScreen(note: items[index]),
                            ),
                          );
                          
                          // Actualizar si hubo cambios
                          if (shouldRefresh == true) {
                            _refresh();
                          }
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteNote(items[index]);
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}