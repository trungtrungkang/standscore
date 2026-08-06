import 'package:flutter/material.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/theme/app_locale_pref.dart';
import 'package:stagescore/theme/app_tokens.dart';

/// Language override sheet (Spec 0057) — "System" plus one entry per
/// [AppLocalePref.supported] locale, each shown in its own endonym.
Future<void> showLanguageSheet({
  required BuildContext context,
  required AppLocalePref pref,
  required ValueChanged<AppLocalePref> onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _LanguageSheet(initial: pref, onChanged: onChanged),
  );
}

class _LanguageSheet extends StatefulWidget {
  const _LanguageSheet({required this.initial, required this.onChanged});

  final AppLocalePref initial;
  final ValueChanged<AppLocalePref> onChanged;

  @override
  State<_LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<_LanguageSheet> {
  late AppLocalePref _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initial;
  }

  void _select(AppLocalePref next) {
    setState(() => _current = next);
    widget.onChanged(next);
  }

  /// "system", or `languageCode` / `languageCode_countryCode` — a stable key
  /// for [RadioListTile]'s single shared `groupValue`.
  static String _keyOf(AppLocalePref pref) {
    if (pref.isSystem) return 'system';
    final country = pref.countryCode;
    return country == null ? pref.languageCode! : '${pref.languageCode}_$country';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = _keyOf(_current);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, AppSpacing.md),
        child: RadioGroup<String>(
          groupValue: selected,
          onChanged: (value) {
            if (value == null) return;
            if (value == 'system') {
              _select(AppLocalePref.system);
              return;
            }
            final locale = AppLocalePref.supported.firstWhere(
              (l) => _keyOf(
                AppLocalePref(
                  languageCode: l.languageCode,
                  countryCode: l.countryCode,
                ),
              ) == value,
            );
            _select(
              AppLocalePref(
                languageCode: locale.languageCode,
                countryCode: locale.countryCode,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Text(
                  l10n.languageSheetTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              RadioListTile<String>(
                value: 'system',
                title: Text(l10n.languageSheetSystem),
                subtitle: Text(l10n.languageSheetSystemSubtitle),
              ),
              for (final locale in AppLocalePref.supported)
                RadioListTile<String>(
                  value: _keyOf(
                    AppLocalePref(
                      languageCode: locale.languageCode,
                      countryCode: locale.countryCode,
                    ),
                  ),
                  title: Text(endonymFor(locale)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
