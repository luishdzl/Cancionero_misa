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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Partituras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.label),
            label: 'Categoria',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.church),
            label: 'Misas',
          ),
        ],
      ),
    );
  }
}