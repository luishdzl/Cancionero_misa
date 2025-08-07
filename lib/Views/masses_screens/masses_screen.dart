import 'package:flutter/material.dart';
import 'package:sqlite_flutter_crud/SQLite/sqlite.dart';
import 'package:sqlite_flutter_crud/JsonModels/mass_model.dart';
import 'package:sqlite_flutter_crud/Views/masses_screens/mass_create_screen.dart';
import 'package:sqlite_flutter_crud/Views/masses_screens/mass_detail_screen.dart';

class MassesScreen extends StatefulWidget {
  const MassesScreen({super.key});

  @override
  State<MassesScreen> createState() => _MassesScreenState();
}

class _MassesScreenState extends State<MassesScreen> {
  final db = DatabaseHelper();
  late Future<List<MassModel>> masses;

  @override
  void initState() {
    super.initState();
    masses = db.getAllMasses();
  }

  Future<void> _refreshMasses() async {
    setState(() {
      masses = db.getAllMasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Misas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MassCreateScreen(),
          ),
        ).then((_) => _refreshMasses()),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<MassModel>>(
        future: masses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final massesList = snapshot.data ?? [];
          
          return ListView.builder(
            itemCount: massesList.length,
            itemBuilder: (context, index) {
              final mass = massesList[index];
              return ListTile(
                title: Text(mass.title),
                subtitle: Text(mass.date),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MassDetailScreen(mass: mass),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}