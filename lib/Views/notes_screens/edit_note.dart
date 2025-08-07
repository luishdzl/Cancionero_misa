import 'package:flutter/material.dart';
import 'package:sqlite_flutter_crud/JsonModels/note_model.dart';
import 'package:sqlite_flutter_crud/JsonModels/tag_model.dart';
import 'package:sqlite_flutter_crud/SQLite/sqlite.dart';
import 'package:sqlite_flutter_crud/widgets/custom_text_field.dart';
import 'package:sqlite_flutter_crud/widgets/select_chord.dart';

class EditNoteScreen extends StatefulWidget {
  final NoteModel note;

  const EditNoteScreen({super.key, required this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late final TextEditingController titleController;
  late final TextEditingController contentController;
  late String? originalKey;
  late String? currentKey;
  final db = DatabaseHelper();
  final formKey = GlobalKey<FormState>();
  
  // Nuevas variables para gestión de etiquetas
  List<String> selectedTags = [];
  List<TagModel> allTags = [];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.noteTitle);
    contentController = TextEditingController(text: widget.note.noteContent);
    originalKey = widget.note.originalKey;
    currentKey = widget.note.currentKey;
    
    // Inicializar etiquetas seleccionadas si existen
    if (widget.note.tags != null) {
      selectedTags = widget.note.tags!;
    }
    
    // Cargar todas las etiquetas disponibles
    _loadTags();
  }

  // Método para cargar etiquetas desde la base de datos
  Future<void> _loadTags() async {
    final tags = await db.getAllTags();
    setState(() {
      allTags = tags;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar partitura"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateNote,
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomTextField(
                controller: titleController,
                labelText: "Título",
                validator: (value) => value!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 16),
              
              // Selector de tono original
              Row(
                children: [
                  Expanded(
                    child: SelectChord(
                      value: originalKey,
                      onChanged: (value) {
                        setState(() {
                          originalKey = value;
                        });
                      },
                      labelText: "Tono original",
                      hintText: "Selecciona un tono",
                      validator: (value) => value == null ? "Requerido" : null,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Selector de tono actual
              Row(
                children: [
                  Expanded(
                    child: SelectChord(
                      value: currentKey,
                      onChanged: (value) {
                        setState(() {
                          currentKey = value;
                        });
                      },
                      labelText: "Tono actual",
                      hintText: "Selecciona un tono",
                      validator: (value) => value == null ? "Requerido" : null,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Sección de etiquetas (nuevo)
              if (allTags.isNotEmpty) ...[
                const Text("Etiquetas:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: allTags.map((tag) {
                    return FilterChip(
                      label: Text(tag.tagName),
                      selected: selectedTags.contains(tag.tagName),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedTags.add(tag.tagName);
                          } else {
                            selectedTags.remove(tag.tagName);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              
              // Contenido de la partitura
              Expanded(
                child: CustomTextField(
                  controller: contentController,
                  labelText: "Contenido de la partitura",
                  hintText: "Acordes en MAYÚSCULAS, letra en minúsculas",
                  expands: true,
                  maxLines: null,
                  validator: (value) => value!.isEmpty ? "Requerido" : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateNote() {
    if (formKey.currentState!.validate()) {
      // Actualizado para incluir las etiquetas
      db.updateNote(
        titleController.text,
        contentController.text,
        originalKey!,
        currentKey!,
        selectedTags, // Nuevo parámetro de etiquetas
        widget.note.noteId!,
      ).then((_) {
        Navigator.pop(context, true);
      });
    }
  }
}