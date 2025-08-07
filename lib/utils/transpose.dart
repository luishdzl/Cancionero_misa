// utils/transpose.dart

// Listas de notas musicales
const List<String> musicKeys = [
  'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
];

const List<String> spanishKeys = [
  'DO', 'DO#', 'RE', 'RE#', 'MI', 'FA', 'FA#', 'SOL', 'SOL#', 'LA', 'LA#', 'SI'
];

// Convertir todas las claves a minúsculas para comparación insensible a mayúsculas
final lowerMusicKeys = musicKeys.map((key) => key.toLowerCase()).toList();
final lowerSpanishKeys = spanishKeys.map((key) => key.toLowerCase()).toList();

// Función para ajustar mayúsculas/minúsculas del acorde
String adjustCase(String newBase, String originalBase) {
  if (originalBase == originalBase.toUpperCase()) {
    return newBase.toUpperCase();
  } else if (originalBase == originalBase.toLowerCase()) {
    return newBase.toLowerCase();
  } else {
    if (newBase.isEmpty) return newBase;
    return newBase[0].toUpperCase() + newBase.substring(1).toLowerCase();
  }
}

// Función para transponer un acorde individual
String transposeSingleChord(String chord, int semitones) {
  // Combinar todas las posibles notas (español e inglés) en minúsculas
  final allKeys = [...lowerSpanishKeys, ...lowerMusicKeys]..sort((a, b) => b.length.compareTo(a.length));
  
  String? baseNote;
  String? rest;
  String lowerChord = chord.toLowerCase();
  
  // Buscar coincidencia más larga posible (insensible a mayúsculas)
  for (final key in allKeys) {
    if (lowerChord.startsWith(key.toLowerCase())) {
      // Mantener el casing original de la base
      baseNote = chord.substring(0, key.length);
      rest = chord.substring(key.length);
      break;
    }
  }

  // Si no encontramos base, retornar acorde original
  if (baseNote == null) return chord;

  final baseUpper = baseNote.toUpperCase();
  int currentIndex;
  
  // Determinar si es acorde español o inglés
  if (spanishKeys.contains(baseUpper)) {
    currentIndex = spanishKeys.indexOf(baseUpper);
  } else if (musicKeys.contains(baseUpper)) {
    currentIndex = musicKeys.indexOf(baseUpper);
  } else {
    return chord;
  }

  // Calcular nuevo índice
  int newIndex = (currentIndex + semitones) % musicKeys.length;
  if (newIndex < 0) newIndex += musicKeys.length;

  // Obtener nueva base
  String newBaseNote;
  if (spanishKeys.contains(baseUpper)) {
    newBaseNote = spanishKeys[newIndex];
  } else {
    newBaseNote = musicKeys[newIndex];
  }

  // Ajustar mayúsculas/minúsculas
  newBaseNote = adjustCase(newBaseNote, baseNote);

  return newBaseNote + rest!;
}

// Función para detectar si una línea contiene acordes
bool isChordLine(String line) {
  // Una línea se considera de acordes si:
  // 1. Contiene al menos un acorde reconocido
  // 2. Tiene una alta densidad de "palabras" que son acordes
  // 3. No contiene palabras completas en minúscula (letras de canción)
  
  // Si la línea está vacía, no es de acordes
  if (line.trim().isEmpty) return false;
  
  // Contar palabras que son acordes
  int chordCount = 0;
  int wordCount = 0;
  
  final words = line.trim().split(RegExp(r'\s+'));
  for (final word in words) {
    if (word.isEmpty) continue;
    wordCount++;
    
    // Verificar si la palabra es un acorde potencial
    bool isChord = false;
    final cleanWord = word.replaceAll(RegExp(r'[^A-Za-z0-9#]'), '').toLowerCase();
    
    // Verificar si comienza con una nota musical
    for (final key in [...lowerSpanishKeys, ...lowerMusicKeys]) {
      if (cleanWord.startsWith(key.toLowerCase())) {
        isChord = true;
        break;
      }
    }
    
    // Contar como acorde si cumple con el patrón
    if (isChord) chordCount++;
  }
  
  // Si no hay palabras, no es línea de acordes
  if (wordCount == 0) return false;
  
  // Criterios para determinar si es línea de acordes:
  // 1. Más del 70% de las palabras son acordes
  // 2. No contiene caracteres de letra minúscula (excepto modificadores de acordes)
  final isChordDense = (chordCount / wordCount) > 0.7;
  final hasLowercaseText = RegExp(r'\b[a-záéíóú]{3,}\b').hasMatch(line);
  
  return isChordDense && !hasLowercaseText;
}

// Función para transponer solo las líneas de acordes
String transposeText(String text, int semitones) {
  final lines = text.split('\n');
  final transposedLines = lines.map((line) {
    if (isChordLine(line)) {
      // Transponer todas las palabras en la línea
      return line.split(' ').map((word) {
        return transposeSingleChord(word, semitones);
      }).join(' ');
    } else {
      // Devolver la línea original sin cambios
      return line;
    }
  }).join('\n');
  
  return transposedLines;
}