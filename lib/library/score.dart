class Score {
  const Score({
    required this.id,
    required this.title,
    required this.relativePath,
    required this.createdAt,
    this.lastOpenedAt,
  });

  final String id;
  final String title;

  /// Path relative to the library root directory (e.g. `scores/<id>.pdf`).
  final String relativePath;
  final DateTime createdAt;
  final DateTime? lastOpenedAt;

  Score copyWith({
    String? title,
    DateTime? lastOpenedAt,
  }) {
    return Score(
      id: id,
      title: title ?? this.title,
      relativePath: relativePath,
      createdAt: createdAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'relativePath': relativePath,
        'createdAt': createdAt.toIso8601String(),
        'lastOpenedAt': lastOpenedAt?.toIso8601String(),
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
    );
  }
}
