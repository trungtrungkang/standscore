import 'package:flutter/material.dart';

/// PdfMode display prefs — page border + system chrome (Spec 0032 / P2.15).
class DisplayPrefs {
  const DisplayPrefs({
    this.borderEnabled = false,
    this.borderWidth = defaultBorderWidth,
    this.borderColorValue = defaultBorderColorValue,
    this.showStatusBar = false,
    this.avoidNotches = true,
  });

  static const defaultBorderWidth = 2.0;
  static const minBorderWidth = 0.5;
  static const maxBorderWidth = 8.0;
  static const defaultBorderColorValue = 0xFF424242;

  final bool borderEnabled;
  final double borderWidth;
  final int borderColorValue;
  final bool showStatusBar;
  final bool avoidNotches;

  Color get borderColor => Color(borderColorValue);

  static double clampBorderWidth(double value) =>
      value.clamp(minBorderWidth, maxBorderWidth).toDouble();

  DisplayPrefs copyWith({
    bool? borderEnabled,
    double? borderWidth,
    int? borderColorValue,
    bool? showStatusBar,
    bool? avoidNotches,
  }) {
    return DisplayPrefs(
      borderEnabled: borderEnabled ?? this.borderEnabled,
      borderWidth: borderWidth != null
          ? clampBorderWidth(borderWidth)
          : this.borderWidth,
      borderColorValue: borderColorValue ?? this.borderColorValue,
      showStatusBar: showStatusBar ?? this.showStatusBar,
      avoidNotches: avoidNotches ?? this.avoidNotches,
    );
  }

  Map<String, dynamic> toJson() => {
        'borderEnabled': borderEnabled,
        'borderWidth': borderWidth,
        'borderColorValue': borderColorValue,
        'showStatusBar': showStatusBar,
        'avoidNotches': avoidNotches,
      };

  factory DisplayPrefs.fromJson(Map<String, dynamic> json) {
    final width = (json['borderWidth'] as num?)?.toDouble();
    return DisplayPrefs(
      borderEnabled: json['borderEnabled'] as bool? ?? false,
      borderWidth: width != null
          ? clampBorderWidth(width)
          : defaultBorderWidth,
      borderColorValue:
          json['borderColorValue'] as int? ?? defaultBorderColorValue,
      showStatusBar: json['showStatusBar'] as bool? ?? false,
      avoidNotches: json['avoidNotches'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DisplayPrefs &&
        other.borderEnabled == borderEnabled &&
        other.borderWidth == borderWidth &&
        other.borderColorValue == borderColorValue &&
        other.showStatusBar == showStatusBar &&
        other.avoidNotches == avoidNotches;
  }

  @override
  int get hashCode => Object.hash(
        borderEnabled,
        borderWidth,
        borderColorValue,
        showStatusBar,
        avoidNotches,
      );
}
