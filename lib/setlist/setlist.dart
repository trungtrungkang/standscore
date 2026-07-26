/// Ordered group of Scores for continuous performance (Spec 0012 / P1.7).
class Setlist {
  const Setlist({
    required this.id,
    required this.title,
    required this.scoreIds,
    required this.createdAt,
    this.lastOpenedAt,
  });

  final String id;
  final String title;

  /// Ordered Score ids (same Score may appear more than once).
  final List<String> scoreIds;
  final DateTime createdAt;
  final DateTime? lastOpenedAt;

  bool get isEmpty => scoreIds.isEmpty;

  Setlist copyWith({
    String? title,
    List<String>? scoreIds,
    DateTime? lastOpenedAt,
  }) {
    return Setlist(
      id: id,
      title: title ?? this.title,
      scoreIds: scoreIds ?? this.scoreIds,
      createdAt: createdAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }

  Setlist rename(String title) => copyWith(title: title.trim().isEmpty ? this.title : title.trim());

  Setlist addScore(String scoreId) {
    if (scoreId.isEmpty) return this;
    return copyWith(scoreIds: [...scoreIds, scoreId]);
  }

  Setlist removeAt(int index) {
    if (index < 0 || index >= scoreIds.length) return this;
    final next = [...scoreIds]..removeAt(index);
    return copyWith(scoreIds: List.unmodifiable(next));
  }

  /// Removes every occurrence of [scoreId] (Spec 0028).
  Setlist removeScoreId(String scoreId) {
    final next = [for (final id in scoreIds) if (id != scoreId) id];
    if (next.length == scoreIds.length) return this;
    return copyWith(scoreIds: List.unmodifiable(next));
  }

  Setlist move(int from, int to) {
    if (from < 0 || from >= scoreIds.length) return this;
    if (to < 0 || to >= scoreIds.length) return this;
    if (from == to) return this;
    final next = [...scoreIds];
    final item = next.removeAt(from);
    next.insert(to, item);
    return copyWith(scoreIds: List.unmodifiable(next));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'scoreIds': scoreIds,
        'createdAt': createdAt.toIso8601String(),
        'lastOpenedAt': lastOpenedAt?.toIso8601String(),
      };

  factory Setlist.fromJson(Map<String, dynamic> json) {
    final raw = json['scoreIds'] as List<dynamic>? ?? const [];
    return Setlist(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Setlist',
      scoreIds: List.unmodifiable(raw.map((e) => e as String)),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastOpenedAt: json['lastOpenedAt'] == null
          ? null
          : DateTime.parse(json['lastOpenedAt'] as String),
    );
  }
}
