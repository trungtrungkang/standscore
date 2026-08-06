import 'package:flutter/widgets.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';

/// English [AppLocalizations] for unit tests that call pure functions taking
/// an `AppLocalizations` parameter — no `BuildContext`/widget tree needed,
/// same as production code loads it through `AppLocalizations.delegate`.
Future<AppLocalizations> testL10n() =>
    AppLocalizations.delegate.load(const Locale('en'));
