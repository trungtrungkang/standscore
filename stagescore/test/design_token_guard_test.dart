import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stagescore/theme/app_tokens.dart';

/// Keeps `lib/ui/` spending token steps instead of raw numbers (Spec 0044).
///
/// This is a **ratchet, not a proof**. It watches four spellings in one folder,
/// so it will never see `Positioned(left: 10)`, a `Container(margin:)`, or a
/// number hidden in an expression — and a locally named constant sidesteps it
/// by design, because "keep the value and give it a name" is the other half of
/// the law in Spec 0044. What it does catch is the thing that actually happens:
/// the next slice adding one more `SizedBox(height: 10)` because 10 looked
/// right on that screen. A number that must stay inline goes in [allowlist]
/// with a reason, so a new exception is a deliberate, readable line in a diff.
///
/// Source-level on purpose, the same reason `brand_reach_test.dart` is
/// (Spec 0042): `PdfModeScreen` cannot be pumped at all, so an invariant about
/// every file in `lib/ui/` cannot be expressed as a widget test.
void main() {
  /// Numbers allowed to stay literal, each with the measurement behind it.
  const allowlist = <String, Map<String, String>>{
    'lib/ui/library_screen.dart': {
      '2':
          'Vertical padding that sits the label chip at the same height as the '
          'compact InputChip above it. _Chip belongs to Spec 0046.',
    },
    'lib/ui/draw_toolbar.dart': {
      '2':
          'Icon-to-label gap, the same measurement as kQuickBarLabelGap '
          '(Spec 0043). DrawToolbar layout belongs to Spec 0049.',
    },
  };

  final spacingSteps = AppSpacing.steps.toSet();
  final radiusSteps = AppRadius.steps.toSet();

  /// `EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom)` nests
  /// parentheses, so the argument list is walked rather than pattern-matched.
  List<String> argumentLists(String source, RegExp opener) {
    final lists = <String>[];
    for (final match in opener.allMatches(source)) {
      var depth = 0;
      var i = match.end - 1;
      for (; i < source.length; i++) {
        if (source[i] == '(') depth++;
        if (source[i] == ')') {
          depth--;
          if (depth == 0) break;
        }
      }
      lists.add(source.substring(match.end, i));
    }
    return lists;
  }

  final edgeInsets = RegExp(r'EdgeInsets\.(?:all|symmetric|only|fromLTRB)\(');
  final sizedBox = RegExp(
    r'SizedBox(?:\.[a-z]+)?\(\s*(?:width|height|dimension):\s*([0-9.]+)',
  );
  final circular = RegExp(r'BorderRadius\.circular\(\s*([0-9.]+)');
  final argument = RegExp(r'(?:^|[(,:])\s*([0-9.]+)\s*(?=[,)]|$)');

  test('lib/ui spends token steps, not numbers', () {
    final offenders = <String>[];

    void check({
      required String path,
      required String literal,
      required Set<double> steps,
      required String what,
    }) {
      final value = double.parse(literal);
      // Zero is not a step and never will be: it is the absence of spacing.
      if (value == 0) return;
      if (allowlist[path]?.containsKey(literal) ?? false) return;
      final named = steps.contains(value)
          ? 'write the step that already equals it'
          : 'snap it to the nearest step, or keep it and name the measurement';
      offenders.add('$path: $what $literal — $named');
    }

    for (final entity in Directory('lib/ui').listSync()) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path;
      final source = entity.readAsStringSync();

      for (final args in argumentLists(source, edgeInsets)) {
        for (final match in argument.allMatches(args)) {
          check(
            path: path,
            literal: match.group(1)!,
            steps: spacingSteps,
            what: 'EdgeInsets holds',
          );
        }
      }
      for (final match in sizedBox.allMatches(source)) {
        check(
          path: path,
          literal: match.group(1)!,
          steps: spacingSteps,
          what: 'SizedBox holds',
        );
      }
      for (final match in circular.allMatches(source)) {
        check(
          path: path,
          literal: match.group(1)!,
          steps: radiusSteps,
          what: 'BorderRadius.circular holds',
        );
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Raw numbers came back into lib/ui. Spend AppSpacing / AppRadius, or '
          'if the number is a measurement rather than taste, name it and add it '
          'to the allowlist in this test (Spec 0044).\n${offenders.join('\n')}',
    );
  });

  test('every allowlisted number is still in the file that claimed it', () {
    allowlist.forEach((path, entries) {
      final source = File(path).readAsStringSync();
      entries.forEach((literal, reason) {
        expect(
          source,
          contains(literal),
          reason:
              'The allowlist still excuses $literal in $path, but the number is '
              'gone. Delete the entry (Spec 0044).',
        );
      });
    });
  });

  test('the drag handle is the theme\'s decision, not each sheet\'s', () {
    final offenders = <String>[];

    for (final entity in Directory('lib/ui').listSync()) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.readAsStringSync().contains('showDragHandle')) {
        offenders.add(entity.path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'A sheet set showDragHandle itself. BottomSheetThemeData in '
          'AppAppearance.themeData owns it, so that a new sheet inherits the '
          'same way out (Spec 0044).',
    );
  });
}
