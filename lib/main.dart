import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqlite_flutter_crud/Authtentication/login.dart';
import 'package:sqlite_flutter_crud/Views/notes_screens/notes.dart';
import 'package:sqlite_flutter_crud/Views/tags_screens/tags_screen.dart';
import 'package:sqlite_flutter_crud/Views/masses_screens/masses_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestor de Partituras',
      localizationsDelegates: const[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
        supportedLocales: const [
        Locale('es', 'ES'), // Español como idioma principal
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 39, 113, 156),
        ), // Paréntesis de cierre añadido aquí
        useMaterial3: true, // Movido fuera de ColorScheme
      ), // Cierre de ThemeData
      home: const LoginScreen(), // Pantalla inicial es el login
      routes: { // Definimos rutas para navegación
        '/main': (context) => const MainScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  // Pantallas correspondientes a cada pestaña
  final List<Widget> _screens = [
    const Notes(),        // Pantalla de partituras
    const TagsScreen(),   // Pantalla de etiquetas
    const MassesScreen(), // Pantalla de misas
  ];

  // Función para mostrar el modal de confirmación de cierre de sesión
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cerrar sesión"),
          content: const Text("¿Estás seguro de que quieres cerrar sesión?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Cerrar sesión", style: TextStyle(color: Colors.red)),
              onPressed: () {
                // Cerrar el modal
                Navigator.of(context).pop();
                // Navegar a la pantalla de login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue[900]!.withOpacity(0.7),
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.music_note, 'Partituras', 0),
                    _buildNavItem(Icons.label, 'Categoria', 1),
                    _buildNavItem(Icons.church, 'Misas', 2),
                    // Botón de cerrar sesión
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10.0),
            child: Icon(
              icon,
              color: isSelected ? Colors.blue[900] : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para el botón de cerrar sesión
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () => _showLogoutConfirmation(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10.0),
            child: const Icon(
              Icons.logout,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Salir',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}