import 'package:stagescore/l10n/gen/app_localizations.dart';

/// How long ago [value] was, in the words a musician would use (Spec 0040).
///
/// Recency is the question the Library list is really asking — the default sort
/// is Last viewed — so the near past reads as "today" / "yesterday" / "5 days
/// ago". Past a week that phrasing gets worse than a date ("42 days ago" is not
/// a fact anyone can place), so it falls back to the plain day.
///
/// Days are counted between local calendar days, not by elapsed hours: 23:50
/// yesterday is "yesterday" at 00:10 today, not "today".
String relativeDay(AppLocalizations l10n, DateTime value, {DateTime? now}) {
  final local = value.toLocal();
  final today = _startOfDay(now?.toLocal() ?? DateTime.now());
  final days = today.difference(_startOfDay(local)).inDays;
  return switch (days) {
    <= 0 => l10n.relativeDayToday,
    1 => l10n.relativeDayYesterday,
    < 7 => l10n.relativeDayDaysAgo(days),
    _ => formatDay(local),
  };
}

/// The plain local day, used once [relativeDay] stops being useful.
String formatDay(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

DateTime _startOfDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);
