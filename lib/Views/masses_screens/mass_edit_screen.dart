import 'package:flutter/material.dart';
import 'package:sqlite_flutter_crud/SQLite/sqlite.dart';
import 'package:sqlite_flutter_crud/JsonModels/mass_model.dart';
import 'package:sqlite_flutter_crud/JsonModels/note_model.dart';
import 'package:sqlite_flutter_crud/Views/masses_screens/select_song_dialog.dart';
import 'package:sqlite_flutter_crud/utils/string_extensions.dart';

class MassEditScreen extends StatefulWidget {
  final MassModel mass;

  const MassEditScreen({super.key, required this.mass});

  @override
  State<MassEditScreen> createState() => _MassEditScreenState();
}

class _MassEditScreenState extends State<MassEditScreen> {
  final db = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  late MassModel mass;
  late TextEditingController _titleController;
  late TextEditingController _dateController;
  
  Map<String, NoteModel?> selectedSongs = {
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
    _titleController = TextEditingController(text: mass.title);
    _dateController = TextEditingController(text: mass.date);
    _loadSongs();
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Future<void> _selectDate(BuildContext context) async {
    // Parsear la fecha actual del controlador
    final parts = _dateController.text.split('-');
    DateTime initialDate = DateTime.now();
    
    if (parts.length == 3) {
      initialDate = DateTime(
        int.tryParse(parts[0]) ?? DateTime.now().year,
        int.tryParse(parts[1]) ?? DateTime.now().month,
        int.tryParse(parts[2]) ?? DateTime.now().day,
      );
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.year}-${_twoDigits(picked.month)}-${_twoDigits(picked.day)}";
      });
    }
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
          selectedSongs[part.capitalize()] = note;
        });
      }
    }
  }

  Future<void> _selectSong(String part) async {
    final note = await showDialog<NoteModel>(
      context: context,
      builder: (context) => const SelectSongDialog(),
    );
    
    if (note != null) {
      setState(() {
        selectedSongs[part] = note;
      });
    }
  }

  Future<void> _saveMass() async {
    if (!_formKey.currentState!.validate()) return;
    
    final newMass = MassModel(
      massId: mass.massId,
      title: _titleController.text,
      date: _dateController.text,
    );
    
    await db.updateMass(newMass);
    Navigator.pop(context, true);
  }

  Widget _buildPartRow(String title, String part) {
    return ListTile(
      title: Text(title),
      subtitle: Text(selectedSongs[part]?.noteTitle ?? 'No seleccionada'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => _selectSong(part),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Misa: ${mass.title}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveMass,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título de la Misa',
                hintText: 'Ej. MISA DOMINGO 18/10/2003',
              ),
              validator: (value) => value!.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Fecha',
                hintText: 'YYYY-MM-DD',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
              readOnly: true, // Evita que el usuario escriba manualmente
              onTap: () => _selectDate(context), // Abre el selector al tocar
              validator: (value) => value!.isEmpty ? 'Requerido' : null,
            ),
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
      ),
    );
  }
}