import 'package:flutter/material.dart';
import 'package:sqlite_flutter_crud/SQLite/sqlite.dart';
import 'package:sqlite_flutter_crud/JsonModels/mass_model.dart';
import 'package:sqlite_flutter_crud/JsonModels/note_model.dart';
import 'package:sqlite_flutter_crud/Views/notes_screens/note_detail.dart';
import 'package:sqlite_flutter_crud/Views/masses_screens/mass_edit_screen.dart';
import 'package:sqlite_flutter_crud/utils/string_extensions.dart'; // Importa aquí

class MassDetailScreen extends StatefulWidget {
  final MassModel mass;

  const MassDetailScreen({super.key, required this.mass});

  @override
  State<MassDetailScreen> createState() => _MassDetailScreenState();
}

class _MassDetailScreenState extends State<MassDetailScreen> {
  final db = DatabaseHelper();
  late MassModel mass;
  Map<String, NoteModel?> songs = {
    'Entrada': null,
    'Piedad': null,
    'Palabra': null,
    'Ofertorio': null,
    'Santo': null,
    'Cordero': null,
    'Comunión': null,
    'Salida': null,
  };

  @override
  void initState() {
    super.initState();
    mass = widget.mass;
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    final parts = [
      'entrada', 'piedad', 'palabra', 'ofertorio',
      'santo', 'cordero', 'comunion', 'salida'
    ];
    
    for (var part in parts) {
      final noteId = mass.toMap()[part];
      if (noteId != null) {
        final note = await db.getNoteById(noteId as int);
        setState(() {
          songs[part.capitalize()] = note; // Usa la extensión importada
        });
      }
    }
  }

  Widget _buildPartRow(String title, String part) {
    final note = songs[part];
    return ListTile(
      title: Text(title),
      subtitle: Text(note?.noteTitle ?? 'No seleccionada'),
      trailing: note != null ? const Icon(Icons.arrow_forward_ios) : null,
      onTap: note != null 
          ? () => _openSongDetail(note!)
          : null,
    );
  }

  void _openSongDetail(NoteModel note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(note: note),
      ),
    );
  }

  void _editMass() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MassEditScreen(mass: mass),
      ),
    ).then((_) {
      // Recargar misa después de editar
      db.getMassById(mass.massId!).then((updatedMass) {
        setState(() {
          mass = updatedMass;
          _loadSongs();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mass.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editMass,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Título: ${mass.title}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Text('Fecha: ${mass.date}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          const Text('Partes de la Misa:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          _buildPartRow('Entrada', 'Entrada'),
          _buildPartRow('Piedad', 'Piedad'),
          _buildPartRow('Palabra', 'Palabra'),
          _buildPartRow('Ofertorio', 'Ofertorio'),
          _buildPartRow('Santo', 'Santo'),
          _buildPartRow('Cordero', 'Cordero'),
          _buildPartRow('Comunión', 'Comunión'),
          _buildPartRow('Salida', 'Salida'),
        ],
      ),
    );
  }
}

// REMOVER LA EXTENSIÓN DE ESTE ARCHIVO