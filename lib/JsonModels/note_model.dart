class NoteModel {
  final int? noteId;
  final String noteTitle;
  final String noteContent;
  final String createdAt;
  final String originalKey;
  final String currentKey;
  final List<String> tags; // Nuevo campo para etiquetas

  NoteModel({
    this.noteId,
    required this.noteTitle,
    required this.noteContent,
    required this.createdAt,
    required this.originalKey,
    required this.currentKey,
    this.tags = const [],
  });

  factory NoteModel.fromMap(Map<String, dynamic> json) => NoteModel(
        noteId: json["noteId"],
        noteTitle: json["noteTitle"],
        noteContent: json["noteContent"],
        createdAt: json["createdAt"],
        originalKey: json["originalKey"] ?? 'C',
        currentKey: json["currentKey"] ?? 'C',
        tags: json["tags"]?.split(',') ?? [],
      );

  Map<String, dynamic> toMap() => {
        "noteId": noteId,
        "noteTitle": noteTitle,
        "noteContent": noteContent,
        "createdAt": createdAt,
        "originalKey": originalKey,
        "currentKey": currentKey,
        "tags": tags.join(','),
      };
  
  NoteModel copyWith({
    int? noteId,
    String? noteTitle,
    String? noteContent,
    String? createdAt,
    String? originalKey,
    String? currentKey,
    List<String>? tags,
  }) {
    return NoteModel(
      noteId: noteId ?? this.noteId,
      noteTitle: noteTitle ?? this.noteTitle,
      noteContent: noteContent ?? this.noteContent,
      createdAt: createdAt ?? this.createdAt,
      originalKey: originalKey ?? this.originalKey,
      currentKey: currentKey ?? this.currentKey,
      tags: tags ?? this.tags,
    );
  }
}