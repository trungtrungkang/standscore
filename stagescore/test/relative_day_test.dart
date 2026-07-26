import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/library/relative_day.dart';

void main() {
  final now = DateTime(2026, 7, 26, 14, 30);

  test('the last week reads as words', () {
    expect(relativeDay(DateTime(2026, 7, 26, 9), now: now), 'today');
    expect(relativeDay(DateTime(2026, 7, 25, 23), now: now), 'yesterday');
    expect(relativeDay(DateTime(2026, 7, 20), now: now), '6 days ago');
  });

  test('a week back falls off to a date', () {
    expect(relativeDay(DateTime(2026, 7, 19), now: now), '2026-07-19');
    expect(relativeDay(DateTime(2024, 11, 3), now: now), '2024-11-03');
  });

  test('days are calendar days, not elapsed hours', () {
    // Ten minutes apart, either side of local midnight.
    final justAfterMidnight = DateTime(2026, 7, 26, 0, 10);
    expect(
      relativeDay(DateTime(2026, 7, 25, 23, 50), now: justAfterMidnight),
      'yesterday',
    );
    expect(
      relativeDay(DateTime(2026, 7, 26, 0, 5), now: justAfterMidnight),
      'today',
    );
  });

  test('a future timestamp is not "-1 days ago"', () {
    expect(relativeDay(DateTime(2026, 7, 27), now: now), 'today');
  });
}
