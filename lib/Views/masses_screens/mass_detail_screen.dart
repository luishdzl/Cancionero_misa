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
Map<String, List<NoteModel>> songs = {
  'Entrada': [],
  'Piedad': [],
  'Palabra': [],
  'Ofertorio': [],
  'Santo': [],
  'Cordero': [],
  'Comunión': [],
  'Salida': [],
};

  @override
  void initState() {
    super.initState();
    mass = widget.mass;
    _loadSongs();
  }
// MODIFICAR _loadSongs
Future<void> _loadSongs() async {
  final parts = [
    'Entrada', 'Piedad', 'Palabra', 'Ofertorio',
    'Santo', 'Cordero', 'Comunión', 'Salida'
  ];
  
  for (var part in parts) {
    final songsForPart = await db.getSongsForMassPart(mass.massId!, part);
    setState(() {
      songs[part] = songsForPart;
    });
  }
}

// MODIFICAR _buildPartRow
Widget _buildPartRow(String title, String part) {
  final songsForPart = songs[part]!;
  return ListTile(
    title: Text(title),
    subtitle: Text(
      songsForPart.isEmpty 
        ? 'No seleccionadas' 
        : songsForPart.map((s) => s.noteTitle).join(', '),
    ),
    trailing: songsForPart.isNotEmpty ? const Icon(Icons.arrow_forward_ios) : null,
    onTap: songsForPart.isNotEmpty 
        ? () => _openSongsForPart(title, songsForPart)
        : null,
  );
}
// NUEVA FUNCIÓN PARA ABRIR CANCIONES
void _openSongsForPart(String title, List<NoteModel> songs) {
  if (songs.length == 1) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(note: songs.first),
      ),
    );
  } else {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: songs.map((song) => ListTile(
            title: Text(song.noteTitle),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailScreen(note: song),
                ),
              );
            },
          )).toList(),
        ),
      ),
    );
  }
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