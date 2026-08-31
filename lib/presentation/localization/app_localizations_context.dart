import 'package:flutter/material.dart';

import 'package:tappin/l10n/app_localizations.dart';
import 'package:tappin/l10n/app_localizations_ja.dart';

/// 現在のBuildContextから表示文言を取得し、単体Widgetでも日本語へ解決する。
extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? AppLocalizationsJa();
}
