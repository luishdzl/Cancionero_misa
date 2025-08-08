import 'package:flutter/material.dart';
import 'package:sqlite_flutter_crud/JsonModels/users.dart';
import 'package:sqlite_flutter_crud/SQLite/sqlite.dart';
import 'package:sqlite_flutter_crud/JsonModels/tag_model.dart';
import 'package:sqlite_flutter_crud/Views/auth_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io'; // Agrega esta línea

class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  final db = DatabaseHelper();
  late Future<List<TagModel>> tags;
  final TextEditingController _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tags = db.getAllTags();
  }

  Future<void> _refreshTags() async {
    setState(() {
      tags = db.getAllTags();
    });
  }

  Future<void> _addTag() async {
    if (_tagController.text.isEmpty) return;
    
    await db.createTag(_tagController.text);
    _tagController.clear();
    _refreshTags();
  }

  Future<void> _deleteTag(int tagId) async {
    final password = await showDialog<String>(
      context: context,
      builder: (context) => const AuthDialog(
        title: 'Confirmar Eliminación',
        message: 'Ingrese su contraseña para eliminar esta Categoria',
      ),
    );
    
    if (password == null) return;
    
    // Verificar contraseña
    final isValid = await db.login(Users(
      usrName: "admin", // Asumir usuario admin
      usrPassword: password,
    ));
    
    if (isValid) {
      try {
        await db.deleteTag(tagId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoria eliminada')),
        );
        _refreshTags();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña incorrecta')),
      );
    }
  }
  
  // Función para importar base de datos
Future<void> _importDatabase() async {
  // Verificar autenticación primero
  final password = await showDialog<String>(
    context: context,
    builder: (context) => const AuthDialog(
      title: 'Importar Base de Datos',
      message: 'Ingrese contraseña de administrador',
    ),
  );
  
  if (password == null) return;
  
  // Validar credenciales
  final isValid = await db.login(Users(
    usrName: "admin",
    usrPassword: password,
  ));
  
  if (!isValid) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contraseña incorrecta')),
    );
    return;
  }

  try {
    // Seleccionar archivo de backup
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowedExtensions: ['db'],
    );

    if (result != null && result.files.isNotEmpty) {
      // Usar File de dart:io
      final file = File(result.files.single.path!);
      await db.importDatabase(file);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Base de datos importada con éxito!')),
        );
        _refreshTags();
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al importar: ${e.toString()}')),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Categorias'),
        actions: [
                    // Botón de importación
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: _importDatabase,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final file = await db.exportDatabase();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Base de datos exportada: ${file.path}')),
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Nueva Categoria'),
              content: TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de Categorias',
                  hintText: 'Ej. Alabanza, Adoración',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addTag();
                    Navigator.pop(context);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<TagModel>>(
        future: tags,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final tagsList = snapshot.data ?? [];
          
          return ListView.builder(
            itemCount: tagsList.length,
            itemBuilder: (context, index) {
              final tag = tagsList[index];
              return ListTile(
                title: Text(tag.tagName),
                trailing: tag.isFixed
                    ? const Icon(Icons.lock, color: Colors.grey)
                    : IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTag(tag.tagId!),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}