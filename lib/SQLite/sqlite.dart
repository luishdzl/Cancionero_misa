import 'dart:io';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite_flutter_crud/JsonModels/note_model.dart';
import 'package:sqlite_flutter_crud/JsonModels/users.dart';
import 'package:sqlite_flutter_crud/JsonModels/tag_model.dart';
import 'package:sqlite_flutter_crud/JsonModels/mass_model.dart';
import 'package:sqlite_flutter_crud/JsonModels/MassSong.dart';

class DatabaseHelper {
  final databaseName = "notes.db";
  late Database db;
  bool isInitialized = false;
  DatabaseHelper();
  String? _databasePath;
// Actualizar el método _initializeDatabase
Future<void> _initializeDatabase() async {
  if (isInitialized) return;
  
  String dbPath;
  if (Platform.isWindows) {
    final assetsDir = join(Directory.current.path, 'lib', 'assets');
    await Directory(assetsDir).create(recursive: true);
    dbPath = join(assetsDir, databaseName);
  } else {
    final docsDir = await getApplicationDocumentsDirectory();
    dbPath = join(docsDir.path, databaseName);
  }

    _databasePath = dbPath;
    db = sqlite3.open(dbPath);

    _createTables();
    _insertFixedTags();
    
    // Insertar usuario admin por defecto si no existe
    db.execute('''
      INSERT OR IGNORE INTO users (usrName, usrPassword)
      VALUES ('admin', 'admin')
    ''');

    isInitialized = true;
  }

  // Función para importar base de datos
  Future<void> importDatabase(File sourceFile) async {
    await _initializeDatabase();
    
    // Cerrar la conexión actual
    db.dispose();
    
    // Reemplazar la base de datos actual con el backup
    await sourceFile.copy(_databasePath!);
    
    // Reabrir la nueva base de datos
    db = sqlite3.open(_databasePath!);
  }

  void _createTables() {
    db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        usrId INTEGER PRIMARY KEY AUTOINCREMENT,
        usrName TEXT UNIQUE,
        usrPassword TEXT
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS notes (
        noteId INTEGER PRIMARY KEY AUTOINCREMENT,
        noteTitle TEXT NOT NULL,
        noteContent TEXT NOT NULL,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
        originalKey TEXT,
        currentKey TEXT,
        tags TEXT,
        audioPath TEXT 
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS tags (
        tagId INTEGER PRIMARY KEY AUTOINCREMENT,
        tagName TEXT UNIQUE,
        isFixed INTEGER DEFAULT 0
      )
    ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS masses (
      massId INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      date TEXT
    )
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS mass_songs (
      massSongId INTEGER PRIMARY KEY AUTOINCREMENT,
      massId INTEGER,
      tagName TEXT,
      noteId INTEGER,
      sortOrder INTEGER DEFAULT 0,
      FOREIGN KEY(massId) REFERENCES masses(massId),
      FOREIGN KEY(noteId) REFERENCES notes(noteId)
    )
  ''');
  }

  void _insertFixedTags() {
    final fixedTags = [
      'Entrada', 'Piedad', 'Palabra', 'Ofertorio', 
      'Santo', 'Cordero', 'Comunión', 'Salida'
    ];

    for (var tag in fixedTags) {
      db.execute('''
        INSERT OR IGNORE INTO tags (tagName, isFixed) 
        VALUES ('$tag', 1)
      ''');
    }
  }

  // Función helper para convertir Row a Map
  Map<String, dynamic> _rowToMap(ResultSet result, int rowIndex) {
    final Map<String, dynamic> map = {};
    for (var i = 0; i < result.columnNames.length; i++) {
      map[result.columnNames[i]] = result[rowIndex][i];
    }
    return map;
  }

  // ========== FUNCIONES DE USUARIO ==========
  Future<bool> login(Users user) async {
    await _initializeDatabase();
    final stmt = db.prepare('''
      SELECT * FROM users 
      WHERE usrName = ? AND usrPassword = ?
    ''');
    final result = stmt.select([user.usrName, user.usrPassword]);
    stmt.dispose();
    return result.isNotEmpty;
  }

  Future<int> signup(Users user) async {
    await _initializeDatabase();
    final stmt = db.prepare('''
      INSERT INTO users (usrName, usrPassword) 
      VALUES (?, ?)
    ''');
    stmt.execute([user.usrName, user.usrPassword]);
    final id = db.lastInsertRowId;
    stmt.dispose();
    return id;
  }

  // ========== FUNCIONES DE NOTAS ==========
  Future<List<NoteModel>> searchNotes(String keyword) async {
    await _initializeDatabase();
    final result = db.select(
      'SELECT * FROM notes WHERE noteTitle LIKE ?',
      ['%$keyword%']
    );
    return List.generate(result.length, (i) => NoteModel.fromMap(_rowToMap(result, i)));
  }

  Future<int> createNote(NoteModel note) async {
    await _initializeDatabase();
    final stmt = db.prepare('''
      INSERT INTO notes (noteTitle, noteContent, createdAt, originalKey, currentKey, tags, audioPath)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    ''');
    
    stmt.execute([
      note.noteTitle,
      note.noteContent,
      note.createdAt,
      note.originalKey,
      note.currentKey,
      note.tags?.join(','),
      note.audioPath  // Nuevo campo
    ]);
    
    final id = db.lastInsertRowId;
    stmt.dispose();
    return id;
  }

  Future<List<NoteModel>> getNotes() async {
    await _initializeDatabase();
    final result = db.select('SELECT * FROM notes');
    return List.generate(result.length, (i) => NoteModel.fromMap(_rowToMap(result, i)));
  }

  Future<int> deleteNote(int id) async {
    await _initializeDatabase();
    final stmt = db.prepare('DELETE FROM notes WHERE noteId = ?');
    stmt.execute([id]);
    final changes = db.getUpdatedRows();
    stmt.dispose();
    return changes;
  }

Future<int> updateNote(
    String title, 
    String content, 
    String originalKey,
    String currentKey,
    List<String>? tags,
    int noteId,
    String? audioPath  // Nuevo parámetro
  ) async {
    await _initializeDatabase();
    final stmt = db.prepare('''
      UPDATE notes 
      SET noteTitle = ?, noteContent = ?, originalKey = ?, currentKey = ?, tags = ?, audioPath = ?
      WHERE noteId = ?
    ''');
    
    stmt.execute([
      title, 
      content, 
      originalKey, 
      currentKey, 
      tags?.join(','),
      audioPath,  // Nuevo campo
      noteId
    ]);
    
    final changes = db.getUpdatedRows();
    stmt.dispose();
    return changes;
  }

  Future<int> updateCurrentKey(int noteId, String newKey) async {
    await _initializeDatabase();
    final stmt = db.prepare('''
      UPDATE notes 
      SET currentKey = ? 
      WHERE noteId = ?
    ''');
    stmt.execute([newKey, noteId]);
    final changes = db.getUpdatedRows();
    stmt.dispose();
    return changes;
  }

  Future<NoteModel> getNoteById(int id) async {
    await _initializeDatabase();
    final result = db.select('SELECT * FROM notes WHERE noteId = ?', [id]);
    if (result.isNotEmpty) {
      return NoteModel.fromMap(_rowToMap(result, 0));
    }
    throw Exception('Note not found');
  }

    // Nuevo método para actualizar solo el audio
  Future<int> updateNoteAudio(int noteId, String audioPath) async {
    await _initializeDatabase();
    final stmt = db.prepare('''
      UPDATE notes 
      SET audioPath = ? 
      WHERE noteId = ?
    ''');
    stmt.execute([audioPath, noteId]);
    final changes = db.getUpdatedRows();
    stmt.dispose();
    return changes;
  }

  // ========== FUNCIONES DE EXPORTACIÓN ==========
// Actualizar el método exportDatabase
Future<File> exportDatabase() async {
  await _initializeDatabase();
  final docsDir = await getApplicationDocumentsDirectory();
  final exportPath = join(docsDir.path, 'backup_${DateTime.now().millisecondsSinceEpoch}.db');
  final file = File(exportPath);
  
  // Usar la ruta almacenada
  await file.writeAsBytes(File(_databasePath!).readAsBytesSync());
  return file;
}

  // ========== FUNCIONES DE ETIQUETAS ==========
  Future<List<TagModel>> getAllTags() async {
    await _initializeDatabase();
    final result = db.select('SELECT * FROM tags');
    return List.generate(result.length, (i) => TagModel.fromMap(_rowToMap(result, i)));
  }

  Future<int> createTag(String tagName) async {
    await _initializeDatabase();
    final stmt = db.prepare('INSERT INTO tags (tagName) VALUES (?)');
    stmt.execute([tagName]);
    final id = db.lastInsertRowId;
    stmt.dispose();
    return id;
  }

  Future<int> deleteTag(int tagId) async {
    await _initializeDatabase();
    // Verificar si es etiqueta fija
    final result = db.select('SELECT isFixed FROM tags WHERE tagId = ?', [tagId]);
    if (result.isNotEmpty && result[0][0] == 1) {
      throw Exception('No se puede eliminar una etiqueta fija');
    }
    
    final stmt = db.prepare('DELETE FROM tags WHERE tagId = ?');
    stmt.execute([tagId]);
    final changes = db.getUpdatedRows();
    stmt.dispose();
    return changes;
  }

  // ========== FUNCIONES DE MISAS ==========
Future<int> createMass(MassModel mass) async {
  await _initializeDatabase();
  final stmt = db.prepare('INSERT INTO masses (title, date) VALUES (?, ?)');
  stmt.execute([mass.title, mass.date]);
  final id = db.lastInsertRowId;
  stmt.dispose();
  return id;
}

Future<List<MassModel>> getAllMasses() async {
  await _initializeDatabase();
  final result = db.select('SELECT * FROM masses ORDER BY date DESC');
  return List.generate(result.length, (i) => MassModel.fromMap(_rowToMap(result, i)));
}
  Future<MassModel> getMassById(int massId) async {
    await _initializeDatabase();
    final result = db.select('SELECT * FROM masses WHERE massId = ?', [massId]);
    if (result.isNotEmpty) {
      return MassModel.fromMap(_rowToMap(result, 0));
    }
    throw Exception('Misa no encontrada');
  }

  Future<int> updateMass(MassModel mass) async {
    await _initializeDatabase();
    final stmt = db.prepare('''
      UPDATE masses SET
        title = ?,
        date = ?,
        entrada = ?,
        piedad = ?,
        palabra = ?,
        ofertorio = ?,
        santo = ?,
        cordero = ?,
        comunion = ?,
        salida = ?
      WHERE massId = ?
    ''');
    
    stmt.execute([
      mass.title,
      mass.date,
      mass.massId
    ]);
    
    final changes = db.getUpdatedRows();
    stmt.dispose();
    return changes;
  }

  // ========== FUNCIONES PARA MASS_SONGS ==========
Future<int> addSongToMass(int massId, String tagName, int noteId) async {
  await _initializeDatabase();
  final stmt = db.prepare('''
    INSERT INTO mass_songs (massId, tagName, noteId)
    VALUES (?, ?, ?)
  ''');
  
  stmt.execute([massId, tagName, noteId]);
  final id = db.lastInsertRowId;
  stmt.dispose();
  return id;
}

Future<List<MassSong>> getSongsForMass(int massId, String tagName) async {
  await _initializeDatabase();
  final result = db.select(
    'SELECT * FROM mass_songs WHERE massId = ? AND tagName = ? ORDER BY sortOrder',
    [massId, tagName]
  );
  return List.generate(result.length, (i) => MassSong.fromMap(_rowToMap(result, i)));
}

Future<List<NoteModel>> getSongsForMassPart(int massId, String tagName) async {
  await _initializeDatabase();
  final result = db.select('''
    SELECT n.* 
    FROM mass_songs ms
    JOIN notes n ON ms.noteId = n.noteId
    WHERE ms.massId = ? AND ms.tagName = ?
    ORDER BY ms.sortOrder
  ''', [massId, tagName]);
  
  return List.generate(result.length, (i) => NoteModel.fromMap(_rowToMap(result, i)));
}

Future<int> removeSongFromMass(int massSongId) async {
  await _initializeDatabase();
  final stmt = db.prepare('DELETE FROM mass_songs WHERE massSongId = ?');
  stmt.execute([massSongId]);
  final changes = db.getUpdatedRows();
  stmt.dispose();
  return changes;
}
}