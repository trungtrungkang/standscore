/// A named page marker on a Score (Spec 0010).
class Bookmark {
  const Bookmark({
    required this.id,
    required this.title,
    required this.pageNumber,
    required this.createdAt,
  });

  final String id;
  final String title;
  final int pageNumber;
  final DateTime createdAt;

  Bookmark copyWith({String? title, int? pageNumber}) {
    return Bookmark(
      id: id,
      title: title ?? this.title,
      pageNumber: pageNumber ?? this.pageNumber,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'pageNumber': pageNumber,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      title: json['title'] as String,
      pageNumber: json['pageNumber'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
