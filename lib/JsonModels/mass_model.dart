class MassModel {
  final int? massId;
  final String title;
  final String date;
  final int? entrada;   // Cambiado de String? a int?
  final int? piedad;    // Cambiado de String? a int?
  final int? palabra;   // Cambiado de String? a int?
  final int? ofertorio; // Cambiado de String? a int?
  final int? santo;     // Cambiado de String? a int?
  final int? cordero;   // Cambiado de String? a int?
  final int? comunion;  // Cambiado de String? a int?
  final int? salida;    // Cambiado de String? a int?

  MassModel({
    this.massId,
    required this.title,
    required this.date,
    this.entrada,
    this.piedad,
    this.palabra,
    this.ofertorio,
    this.santo,
    this.cordero,
    this.comunion,
    this.salida,
  });

  factory MassModel.fromMap(Map<String, dynamic> json) => MassModel(
        massId: json["massId"],
        title: json["title"],
        date: json["date"],
        entrada: json["entrada"],
        piedad: json["piedad"],
        palabra: json["palabra"],
        ofertorio: json["ofertorio"],
        santo: json["santo"],
        cordero: json["cordero"],
        comunion: json["comunion"],
        salida: json["salida"],
      );

  Map<String, dynamic> toMap() => {
        "massId": massId,
        "title": title,
        "date": date,
        "entrada": entrada,
        "piedad": piedad,
        "palabra": palabra,
        "ofertorio": ofertorio,
        "santo": santo,
        "cordero": cordero,
        "comunion": comunion,
        "salida": salida,
      };
}