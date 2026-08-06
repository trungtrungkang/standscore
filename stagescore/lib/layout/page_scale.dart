import 'package:stagescore/l10n/gen/app_localizations.dart';

/// Page scale scope for Spec 0031 / P2.14.
enum PageScaleScope { fixed, perScore, perPage }

extension PageScaleScopeX on PageScaleScope {
  String label(AppLocalizations l10n) => switch (this) {
    PageScaleScope.fixed => l10n.pageScaleScopeFixed,
    PageScaleScope.perScore => l10n.pageScaleScopePerScore,
    PageScaleScope.perPage => l10n.pageScaleScopePerPage,
  };
}

/// App + Score + page scale preferences (inheritance: page → score → fixed).
class PageScalePrefs {
  const PageScalePrefs({
    this.editScope = PageScaleScope.fixed,
    this.locked = false,
    this.fixedScale = defaultScale,
    this.scoreScales = const {},
    this.pageScales = const {},
  });

  static const defaultScale = 1.0;
  static const minScale = 0.5;
  static const maxScale = 1.5;

  /// Which scope the Page scale sheet edits.
  final PageScaleScope editScope;
  final bool locked;
  final double fixedScale;

  /// scoreId → scale
  final Map<String, double> scoreScales;

  /// `"$scoreId:$sourcePage"` → scale, where `sourcePage` is the **absolute**
  /// 1-based page of the Score's PdfDocument — the same space annotations and
  /// `PageOrderEntry.sourcePage` live in, never a page within a PageExtent.
  final Map<String, double> pageScales;

  static double clampScale(double value) =>
      value.clamp(minScale, maxScale).toDouble();

  static String pageKey(String scoreId, int sourcePage) =>
      '$scoreId:$sourcePage';

  /// Effective scale for a Score page (page override → score → fixed).
  double resolve({required String scoreId, required int? sourcePage}) {
    if (sourcePage != null) {
      final page = pageScales[pageKey(scoreId, sourcePage)];
      if (page != null) return clampScale(page);
    }
    final score = scoreScales[scoreId];
    if (score != null) return clampScale(score);
    return clampScale(fixedScale);
  }

  /// Scale currently shown/edited for [editScope] in the sheet.
  double scaleForEdit({required String scoreId, required int? sourcePage}) {
    switch (editScope) {
      case PageScaleScope.fixed:
        return clampScale(fixedScale);
      case PageScaleScope.perScore:
        return clampScale(scoreScales[scoreId] ?? fixedScale);
      case PageScaleScope.perPage:
        if (sourcePage == null) {
          return clampScale(scoreScales[scoreId] ?? fixedScale);
        }
        return resolve(scoreId: scoreId, sourcePage: sourcePage);
    }
  }

  PageScalePrefs withEditedScale({
    required String scoreId,
    required int? sourcePage,
    required double scale,
  }) {
    final clamped = clampScale(scale);
    switch (editScope) {
      case PageScaleScope.fixed:
        return copyWith(fixedScale: clamped);
      case PageScaleScope.perScore:
        return copyWith(scoreScales: {...scoreScales, scoreId: clamped});
      case PageScaleScope.perPage:
        if (sourcePage == null) {
          return copyWith(scoreScales: {...scoreScales, scoreId: clamped});
        }
        return copyWith(
          pageScales: {...pageScales, pageKey(scoreId, sourcePage): clamped},
        );
    }
  }

  /// Hand each per-page override to whichever Score now owns that page
  /// (Spec 0052).
  ///
  /// Splitting a book leaves every page override keyed to the book's Score id,
  /// which after a split is only the *first* piece — so an override on page 90
  /// would be orphaned the moment the split happened. [ownerOf] answers with
  /// the Score id owning an absolute page, or null when no piece covers it;
  /// overrides with no owner are dropped, because the page belongs to nothing.
  PageScalePrefs reassignPageScales({
    required String scoreId,
    required String? Function(int sourcePage) ownerOf,
  }) {
    final prefix = '$scoreId:';
    final reassigned = <String, double>{};
    for (final entry in pageScales.entries) {
      if (!entry.key.startsWith(prefix)) {
        reassigned[entry.key] = entry.value;
        continue;
      }
      final page = int.tryParse(entry.key.substring(prefix.length));
      if (page == null) {
        reassigned[entry.key] = entry.value;
        continue;
      }
      final owner = ownerOf(page);
      if (owner == null) continue;
      reassigned[pageKey(owner, page)] = entry.value;
    }
    return copyWith(pageScales: reassigned);
  }

  PageScalePrefs copyWith({
    PageScaleScope? editScope,
    bool? locked,
    double? fixedScale,
    Map<String, double>? scoreScales,
    Map<String, double>? pageScales,
  }) {
    return PageScalePrefs(
      editScope: editScope ?? this.editScope,
      locked: locked ?? this.locked,
      fixedScale: fixedScale != null ? clampScale(fixedScale) : this.fixedScale,
      scoreScales: scoreScales ?? this.scoreScales,
      pageScales: pageScales ?? this.pageScales,
    );
  }

  Map<String, dynamic> toJson() => {
    'editScope': editScope.name,
    'locked': locked,
    'fixedScale': fixedScale,
    'scoreScales': scoreScales,
    'pageScales': pageScales,
  };

  factory PageScalePrefs.fromJson(Map<String, dynamic> json) {
    PageScaleScope scope = PageScaleScope.fixed;
    final scopeName = json['editScope'] as String?;
    for (final value in PageScaleScope.values) {
      if (value.name == scopeName) {
        scope = value;
        break;
      }
    }
    Map<String, double> readMap(String key) {
      final raw = json[key];
      if (raw is! Map) return const {};
      return {
        for (final e in raw.entries)
          if (e.value is num)
            e.key.toString(): clampScale((e.value as num).toDouble()),
      };
    }

    return PageScalePrefs(
      editScope: scope,
      locked: json['locked'] as bool? ?? false,
      fixedScale: clampScale(
        (json['fixedScale'] as num?)?.toDouble() ?? defaultScale,
      ),
      scoreScales: readMap('scoreScales'),
      pageScales: readMap('pageScales'),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PageScalePrefs &&
        other.editScope == editScope &&
        other.locked == locked &&
        other.fixedScale == fixedScale &&
        _mapEquals(other.scoreScales, scoreScales) &&
        _mapEquals(other.pageScales, pageScales);
  }

  @override
  int get hashCode => Object.hash(
    editScope,
    locked,
    fixedScale,
    Object.hashAll(scoreScales.entries),
    Object.hashAll(pageScales.entries),
  );
}

bool _mapEquals(Map<String, double> a, Map<String, double> b) {
  if (a.length != b.length) return false;
  for (final e in a.entries) {
    if (b[e.key] != e.value) return false;
  }
  return true;
}
