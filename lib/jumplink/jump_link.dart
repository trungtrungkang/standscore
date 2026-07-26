import 'dart:ui';

/// On-page tap target that jumps to another performance page (Spec 0016).
class JumpLink {
  const JumpLink({
    required this.id,
    required this.originPage,
    required this.destinationPage,
    required this.normRect,
    required this.colorValue,
    required this.createdAt,
  });

  final String id;

  /// 1-based PageOrder page where the button is drawn.
  final int originPage;

  /// 1-based PageOrder destination page.
  final int destinationPage;

  /// Normalized rect on the page content (0–1 in both axes).
  final Rect normRect;

  /// ARGB color for the button fill.
  final int colorValue;

  final DateTime createdAt;

  Color get color => Color(colorValue);

  JumpLink copyWith({
    int? destinationPage,
    Rect? normRect,
    int? colorValue,
  }) {
    return JumpLink(
      id: id,
      originPage: originPage,
      destinationPage: destinationPage ?? this.destinationPage,
      normRect: normRect ?? this.normRect,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'originPage': originPage,
        'destinationPage': destinationPage,
        'nx': normRect.left,
        'ny': normRect.top,
        'nw': normRect.width,
        'nh': normRect.height,
        'color': colorValue,
        'createdAt': createdAt.toIso8601String(),
      };

  factory JumpLink.fromJson(Map<String, dynamic> json) {
    return JumpLink(
      id: json['id'] as String,
      originPage: json['originPage'] as int,
      destinationPage: json['destinationPage'] as int,
      normRect: Rect.fromLTWH(
        (json['nx'] as num).toDouble(),
        (json['ny'] as num).toDouble(),
        (json['nw'] as num).toDouble(),
        (json['nh'] as num).toDouble(),
      ),
      colorValue: json['color'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Default button placement (bottom-right corner of the page).
Rect defaultJumpLinkNormRect() => const Rect.fromLTWH(0.72, 0.86, 0.24, 0.08);

/// Default teal button (ARGB).
const int defaultJumpLinkColorValue = 0xCC0D9488;
