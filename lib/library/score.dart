class Score {
  const Score({
    required this.id,
    required this.title,
    required this.relativePath,
    required this.createdAt,
    this.lastOpenedAt,
    this.pageCount,
  });

  final String id;
  final String title;

  /// Path relative to the library root directory (e.g. `scores/<id>.pdf`).
  final String relativePath;
  final DateTime createdAt;
  final DateTime? lastOpenedAt;

  /// Pages in the source PDF, or null until it has been counted (Spec 0040).
  ///
  /// Nullable because Scores imported before 0040 have never been opened for
  /// counting, and because the Library list must render before every PDF on
  /// disk has been read.
  final int? pageCount;

  Score copyWith({String? title, DateTime? lastOpenedAt, int? pageCount}) {
    return Score(
      id: id,
      title: title ?? this.title,
      relativePath: relativePath,
      createdAt: createdAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      pageCount: pageCount ?? this.pageCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'relativePath': relativePath,
    'createdAt': createdAt.toIso8601String(),
    'lastOpenedAt': lastOpenedAt?.toIso8601String(),
    'pageCount': pageCount,
  };

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      id: json['id'] as String,
      title: json['title'] as String,
      relativePath: json['relativePath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastOpenedAt: json['lastOpenedAt'] == null
          ? null
          : DateTime.parse(json['lastOpenedAt'] as String),
      pageCount: json['pageCount'] as int?,
    );
  }
}
