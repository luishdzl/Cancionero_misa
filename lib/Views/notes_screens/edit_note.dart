import 'package:flutter/material.dart';
import 'package:sqlite_flutter_crud/JsonModels/note_model.dart';
import 'package:sqlite_flutter_crud/JsonModels/tag_model.dart';
import 'package:sqlite_flutter_crud/SQLite/sqlite.dart';
import 'package:sqlite_flutter_crud/widgets/custom_text_field.dart';
import 'package:sqlite_flutter_crud/widgets/select_chord.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
  String? audioPath;
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
    audioPath = widget.note.audioPath; 
    
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

  // Función para seleccionar audio
  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final savedFile = File('${appDir.path}/$fileName');
      
      await file.copy(savedFile.path);
      
      setState(() {
        audioPath = savedFile.path;
      });
    }
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
        child: SingleChildScrollView(  // Cambiado a SingleChildScrollView
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,  // Añadido
            children: [
              CustomTextField(
                controller: titleController,
                labelText: "Título",
                validator: (value) => value!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 16),
              
              // Selector de tono original
              SelectChord(  // Simplificado - sin Row
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
              
              const SizedBox(height: 16),
              
              // Selector de tono actual
              SelectChord(  // Simplificado - sin Row
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
              
              const SizedBox(height: 16),
              
              // Sección de audio
              Card(
                child: ListTile(
                  leading: const Icon(Icons.audio_file),
                  title: const Text('Audio asociado'),
                  subtitle: audioPath != null 
                      ? Text('Archivo: ${audioPath!.split('/').last}')
                      : const Text('Ningún audio seleccionado'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (audioPath != null) IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () {
                          // Reproducir audio (implementar con paquete de audio)
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: _pickAudio,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Sección de etiquetas
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
              CustomTextField(
                controller: contentController,
                labelText: "Contenido de la partitura",
                hintText: "Acordes en MAYÚSCULAS, letra en minúsculas",
                maxLines: 15,  // Cambiado de expands a maxLines
                minLines: 8,    // Define un rango de líneas
                validator: (value) => value!.isEmpty ? "Requerido" : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateNote() {
    if (formKey.currentState!.validate()) {
      db.updateNote(
        titleController.text,
        contentController.text,
        originalKey!,
        currentKey!,
        selectedTags,
        widget.note.noteId!,
        audioPath,
      ).then((_) {
        Navigator.pop(context, true);
      });
    }
  }
}