import 'package:flutter/material.dart';
import 'package:sqlite_flutter_crud/JsonModels/note_model.dart';
import 'package:sqlite_flutter_crud/JsonModels/tag_model.dart'; // Importar modelo de tags
import 'package:sqlite_flutter_crud/SQLite/sqlite.dart';
import 'package:sqlite_flutter_crud/widgets/custom_text_field.dart';
import 'package:sqlite_flutter_crud/widgets/select_chord.dart';

class CreateNote extends StatefulWidget {
  const CreateNote({super.key});

  @override
  State<CreateNote> createState() => _CreateNoteState();
}

class _CreateNoteState extends State<CreateNote> {
  final title = TextEditingController();
  final content = TextEditingController();
  String? selectedKey;
  final formKey = GlobalKey<FormState>();
  final db = DatabaseHelper();
  List<String> selectedTags = [];
  List<TagModel> allTags = []; // Lista para almacenar todos los tags

  @override
  void initState() {
    super.initState();
    _loadTags(); // Cargar tags al iniciar
  }

  // Función para cargar tags desde la base de datos
  void _loadTags() async {
    final tags = await db.getAllTags();
    setState(() {
      allTags = tags;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear partitura")),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomTextField(
                controller: title,
                labelText: "Título",
                validator: (value) => value!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 16),
              SelectChord(
                value: selectedKey,
                onChanged: (value) {
                  setState(() {
                    selectedKey = value;
                  });
                },
                labelText: "Tono original",
                hintText: "Selecciona un tono",
                validator: (value) => value == null ? "Requerido" : null,
              ),
              
              // SECCIÓN DE ETIQUETAS - NUEVO CÓDIGO INTEGRADO
              const SizedBox(height: 16),
              const Text("Etiquetas:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              if (allTags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
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
              // FIN DE SECCIÓN DE ETIQUETAS
              
              Expanded(
                child: CustomTextField(
                  controller: content,
                  labelText: "Contenido de la partitura",
                  hintText: "Acordes en MAYÚSCULAS, letra en minúsculas\n\nEjemplo:\n\n[C]         [F]\nLetra en minúscula\n[G]         [C]\nOtro acorde",
                  expands: true,
                  maxLines: null,
                  validator: (value) => value!.isEmpty ? "Requerido" : null,
                ),
              ),
            ],
          ),
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            await db.createNote(NoteModel(
              noteTitle: title.text,
              noteContent: content.text,
              createdAt: DateTime.now().toIso8601String(),
              originalKey: selectedKey!,
              currentKey: selectedKey!,
              tags: selectedTags, // Añadir tags seleccionados - NUEVO
            ));
            Navigator.pop(context, true);
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}