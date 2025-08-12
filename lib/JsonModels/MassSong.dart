class MassSong {
  final int? massSongId;
  final int massId;
  final String tagName;
  final int noteId;
  final int sortOrder;

  MassSong({
    this.massSongId,
    required this.massId,
    required this.tagName,
    required this.noteId,
    this.sortOrder = 0,
  });

  factory MassSong.fromMap(Map<String, dynamic> json) => MassSong(
        massSongId: json["massSongId"],
        massId: json["massId"],
        tagName: json["tagName"],
        noteId: json["noteId"],
        sortOrder: json["sortOrder"] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        "massSongId": massSongId,
        "massId": massId,
        "tagName": tagName,
        "noteId": noteId,
        "sortOrder": sortOrder,
      };
}