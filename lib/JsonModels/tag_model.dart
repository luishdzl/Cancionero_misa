class TagModel {
  final int? tagId;
  final String tagName;
  final bool isFixed;

  TagModel({
    this.tagId,
    required this.tagName,
    this.isFixed = false,
  });

  factory TagModel.fromMap(Map<String, dynamic> json) => TagModel(
        tagId: json["tagId"],
        tagName: json["tagName"],
        isFixed: json["isFixed"] == 1,
      );

  Map<String, dynamic> toMap() => {
        "tagId": tagId,
        "tagName": tagName,
        "isFixed": isFixed ? 1 : 0,
      };
}