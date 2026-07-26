/// User-defined Library Label (Spec 0021 / P2.5).
class Label {
  const Label({required this.id, required this.name});

  final String id;
  final String name;

  Label copyWith({String? name}) => Label(id: id, name: name ?? this.name);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Label.fromJson(Map<String, dynamic> json) {
    return Label(id: json['id'] as String, name: json['name'] as String);
  }
}

/// How selected Labels match Scores in the Library filter.
enum LabelFilterMode {
  /// Score has at least one of the selected Labels.
  any,

  /// Score has every selected Label.
  all,

  /// Score has no Labels (selected Labels ignored).
  untagged,
}
