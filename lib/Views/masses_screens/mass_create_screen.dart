import 'package:flutter/material.dart';
import 'package:sqlite_flutter_crud/SQLite/sqlite.dart';
import 'package:sqlite_flutter_crud/JsonModels/mass_model.dart';
import 'package:sqlite_flutter_crud/JsonModels/note_model.dart';
import 'package:sqlite_flutter_crud/Views/masses_screens/select_song_dialog.dart';

class MassCreateScreen extends StatefulWidget {
  const MassCreateScreen({super.key});

  @override
  State<MassCreateScreen> createState() => _MassCreateScreenState();
}

class _MassCreateScreenState extends State<MassCreateScreen> {
  final db = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  
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
    // Establecer fecha actual al inicializar
    _setCurrentDate();
  }

  void _setCurrentDate() {
    final now = DateTime.now();
    final formattedDate = "${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}";
    _dateController.text = formattedDate;
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.year}-${_twoDigits(picked.month)}-${_twoDigits(picked.day)}";
      });
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

  Future<void> _createMass() async {
    if (!_formKey.currentState!.validate()) return;
    
    final newMass = MassModel(
      title: _titleController.text,
      date: _dateController.text,
      entrada: selectedSongs['Entrada']?.noteId,
      piedad: selectedSongs['Piedad']?.noteId,
      palabra: selectedSongs['Palabra']?.noteId,
      ofertorio: selectedSongs['Ofertorio']?.noteId,
      santo: selectedSongs['Santo']?.noteId,
      cordero: selectedSongs['Cordero']?.noteId,
      comunion: selectedSongs['Comunión']?.noteId,
      salida: selectedSongs['Salida']?.noteId,
    );
    
    await db.createMass(newMass);
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
        title: const Text('Crear Nueva Misa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _createMass,
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