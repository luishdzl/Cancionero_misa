class MassModel {
  final int? massId;
  final String title;
  final String date;
  
  MassModel({
    this.massId,
    required this.title,
    required this.date,
  });

  factory MassModel.fromMap(Map<String, dynamic> json) => MassModel(
        massId: json["massId"],
        title: json["title"],
        date: json["date"],
      );

  Map<String, dynamic> toMap() => {
        "massId": massId,
        "title": title,
        "date": date,
      };
}