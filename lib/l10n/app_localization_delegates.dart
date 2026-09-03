import 'package:material_ui/material_ui.dart';

import 'app_localizations.dart' as gen;

/// The localization delegates a [MaterialApp] built from `material_ui` needs.
///
/// `flutter gen-l10n` doesn't yet know about the material_ui/cupertino_ui
/// split: [gen.AppLocalizations.localizationsDelegates] still wires in the
/// legacy `flutter_localizations` `Global*Localizations` delegates, whose
/// `MaterialLocalizations`/`CupertinoLocalizations` types no longer match
/// what a `material_ui` `MaterialApp` looks up, breaking every non-English
/// locale. Use this list instead everywhere a `MaterialApp` needs
/// [gen.AppLocalizations] until gen-l10n's template is updated upstream.
/// Hand-written, not generated — safe from `flutter gen-l10n` regeneration.
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates = [
  gen.AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];
