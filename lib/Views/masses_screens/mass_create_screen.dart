import 'package:flutter/material.dart';
import 'package:sqlite_flutter_crud/SQLite/sqlite.dart';
import 'package:sqlite_flutter_crud/JsonModels/mass_model.dart';
import 'package:sqlite_flutter_crud/JsonModels/note_model.dart';
import 'package:sqlite_flutter_crud/widgets/MultiSelectDialog.dart';

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
  
Map<String, List<NoteModel>> selectedSongs = {
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

Future<void> _selectSongs(String part) async {
  final notes = await showDialog<List<NoteModel>>(
    context: context,
    builder: (context) => MultiSelectDialog(selectedNotes: selectedSongs[part]!),
  );
  
  if (notes != null) {
    setState(() {
      selectedSongs[part] = notes;
    });
  }
}

// MODIFICAR _createMass/_saveMass
Future<void> _createMass() async {
  if (!_formKey.currentState!.validate()) return;
  
  final massId = await db.createMass(MassModel(
    title: _titleController.text,
    date: _dateController.text,
  ));
  
  // Guardar todas las canciones
  for (var part in selectedSongs.keys) {
    for (var song in selectedSongs[part]!) {
      await db.addSongToMass(massId, part, song.noteId!);
    }
  }
  
  Navigator.pop(context, true);
}

Widget _buildPartRow(String title, String part) {
  final songs = selectedSongs[part]!;
  return ListTile(
    title: Text(title),
    subtitle: Text(
      songs.isEmpty 
        ? 'No seleccionadas' 
        : songs.map((s) => s.noteTitle).join(', '),
    ),
    trailing: const Icon(Icons.arrow_forward_ios),
    onTap: () => _selectSongs(part),
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