import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ja')];

  /// No description provided for @appTitle.
  ///
  /// In ja, this message translates to:
  /// **'Tappin'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In ja, this message translates to:
  /// **'編集'**
  String get edit;

  /// No description provided for @errorWithDetail.
  ///
  /// In ja, this message translates to:
  /// **'エラー: {error}'**
  String errorWithDetail(String error);

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In ja, this message translates to:
  /// **'Tappin へようこそ'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDescription.
  ///
  /// In ja, this message translates to:
  /// **'気になった場所を見つけたら、その場でワンタップ。\n場所と時間をすぐに記録できます。'**
  String get onboardingWelcomeDescription;

  /// No description provided for @onboardingReviewTitle.
  ///
  /// In ja, this message translates to:
  /// **'あとから場所を確認'**
  String get onboardingReviewTitle;

  /// No description provided for @onboardingReviewDescription.
  ///
  /// In ja, this message translates to:
  /// **'記録した場所は、あとから地図で確認できます。\n分かったことはメモに残せます。'**
  String get onboardingReviewDescription;

  /// No description provided for @onboardingQuickModeTitle.
  ///
  /// In ja, this message translates to:
  /// **'すばやく記録する Quick Mode'**
  String get onboardingQuickModeTitle;

  /// No description provided for @onboardingQuickModeDescription.
  ///
  /// In ja, this message translates to:
  /// **'画面のどこをタップしても現在地を記録できます。\n運転中は操作せず、同乗中など安全な状況でお使いください。'**
  String get onboardingQuickModeDescription;

  /// No description provided for @onboardingPrivacyTitle.
  ///
  /// In ja, this message translates to:
  /// **'位置情報について'**
  String get onboardingPrivacyTitle;

  /// No description provided for @onboardingPrivacyDescription.
  ///
  /// In ja, this message translates to:
  /// **'位置情報は場所の記録にのみ使用します。\n記録したデータは端末内に保存され、外部には送信されません。'**
  String get onboardingPrivacyDescription;

  /// No description provided for @start.
  ///
  /// In ja, this message translates to:
  /// **'はじめる'**
  String get start;

  /// No description provided for @next.
  ///
  /// In ja, this message translates to:
  /// **'次へ'**
  String get next;

  /// No description provided for @homeTagline.
  ///
  /// In ja, this message translates to:
  /// **'気になった場所を記録しよう。'**
  String get homeTagline;

  /// No description provided for @record.
  ///
  /// In ja, this message translates to:
  /// **'記録'**
  String get record;

  /// No description provided for @pinHere.
  ///
  /// In ja, this message translates to:
  /// **'場所を記録'**
  String get pinHere;

  /// No description provided for @history.
  ///
  /// In ja, this message translates to:
  /// **'履歴'**
  String get history;

  /// No description provided for @unreviewedCountCompact.
  ///
  /// In ja, this message translates to:
  /// **'未確認 {count}'**
  String unreviewedCountCompact(int count);

  /// No description provided for @quickMode.
  ///
  /// In ja, this message translates to:
  /// **'Quick Mode'**
  String get quickMode;

  /// No description provided for @quickModeGuide.
  ///
  /// In ja, this message translates to:
  /// **'画面全体をタップして、\nすばやく現在地を記録できます。\n運転者は操作しないでください。'**
  String get quickModeGuide;

  /// No description provided for @startQuickMode.
  ///
  /// In ja, this message translates to:
  /// **'Quick Modeをはじめる'**
  String get startQuickMode;

  /// No description provided for @checkingPlace.
  ///
  /// In ja, this message translates to:
  /// **'場所を確認中…'**
  String get checkingPlace;

  /// No description provided for @coordinateRecorded.
  ///
  /// In ja, this message translates to:
  /// **'位置を記録しました'**
  String get coordinateRecorded;

  /// No description provided for @justPinned.
  ///
  /// In ja, this message translates to:
  /// **'記録しました'**
  String get justPinned;

  /// No description provided for @historyTitle.
  ///
  /// In ja, this message translates to:
  /// **'記録をふりかえる'**
  String get historyTitle;

  /// No description provided for @historyLoadError.
  ///
  /// In ja, this message translates to:
  /// **'記録を読み込めませんでした\n{error}'**
  String historyLoadError(String error);

  /// No description provided for @historyDescription.
  ///
  /// In ja, this message translates to:
  /// **'記録した場所を、ひとつずつ確認できます。'**
  String get historyDescription;

  /// No description provided for @unreviewedCount.
  ///
  /// In ja, this message translates to:
  /// **'未確認  {count}'**
  String unreviewedCount(int count);

  /// No description provided for @reviewedCount.
  ///
  /// In ja, this message translates to:
  /// **'確認済み  {count}'**
  String reviewedCount(int count);

  /// No description provided for @noPinsTitle.
  ///
  /// In ja, this message translates to:
  /// **'まだ記録がありません'**
  String get noPinsTitle;

  /// No description provided for @noPinsDescription.
  ///
  /// In ja, this message translates to:
  /// **'気になった場所を記録してみましょう。'**
  String get noPinsDescription;

  /// No description provided for @noUnreviewedTitle.
  ///
  /// In ja, this message translates to:
  /// **'未確認の記録はありません'**
  String get noUnreviewedTitle;

  /// No description provided for @noReviewedTitle.
  ///
  /// In ja, this message translates to:
  /// **'確認済みの記録はありません'**
  String get noReviewedTitle;

  /// No description provided for @noUnreviewedDescription.
  ///
  /// In ja, this message translates to:
  /// **'新しく記録した場所がここに表示されます。'**
  String get noUnreviewedDescription;

  /// No description provided for @noReviewedDescription.
  ///
  /// In ja, this message translates to:
  /// **'確認を終えた記録がここに表示されます。'**
  String get noReviewedDescription;

  /// No description provided for @reviewLater.
  ///
  /// In ja, this message translates to:
  /// **'あとで確認'**
  String get reviewLater;

  /// No description provided for @reviewed.
  ///
  /// In ja, this message translates to:
  /// **'確認済み'**
  String get reviewed;

  /// No description provided for @noMemo.
  ///
  /// In ja, this message translates to:
  /// **'メモなし'**
  String get noMemo;

  /// No description provided for @checkPlaceAction.
  ///
  /// In ja, this message translates to:
  /// **'場所を確認する  →'**
  String get checkPlaceAction;

  /// No description provided for @historyDate.
  ///
  /// In ja, this message translates to:
  /// **'{month}/{day} {hour}:{minute}'**
  String historyDate(String month, String day, String hour, String minute);

  /// No description provided for @pinDetailTitle.
  ///
  /// In ja, this message translates to:
  /// **'記録の詳細'**
  String get pinDetailTitle;

  /// No description provided for @deletePinTooltip.
  ///
  /// In ja, this message translates to:
  /// **'記録を削除'**
  String get deletePinTooltip;

  /// No description provided for @deletePinTitle.
  ///
  /// In ja, this message translates to:
  /// **'この記録を削除しますか？'**
  String get deletePinTitle;

  /// No description provided for @deletePinDescription.
  ///
  /// In ja, this message translates to:
  /// **'削除した記録は元に戻せません。'**
  String get deletePinDescription;

  /// No description provided for @reviewLaterRecord.
  ///
  /// In ja, this message translates to:
  /// **'未確認の記録'**
  String get reviewLaterRecord;

  /// No description provided for @checkingAddress.
  ///
  /// In ja, this message translates to:
  /// **'住所を確認中…'**
  String get checkingAddress;

  /// No description provided for @pinRecordedAt.
  ///
  /// In ja, this message translates to:
  /// **'{year}/{month}/{day} {hour}:{minute} に記録'**
  String pinRecordedAt(
    String year,
    String month,
    String day,
    String hour,
    String minute,
  );

  /// No description provided for @pinDateTime.
  ///
  /// In ja, this message translates to:
  /// **'{year}/{month}/{day} {hour}:{minute}'**
  String pinDateTime(
    String year,
    String month,
    String day,
    String hour,
    String minute,
  );

  /// No description provided for @researchPlaceTitle.
  ///
  /// In ja, this message translates to:
  /// **'場所を確認'**
  String get researchPlaceTitle;

  /// No description provided for @externalMapDescription.
  ///
  /// In ja, this message translates to:
  /// **'外部の地図アプリを開きます。'**
  String get externalMapDescription;

  /// No description provided for @findingsTitle.
  ///
  /// In ja, this message translates to:
  /// **'メモ'**
  String get findingsTitle;

  /// No description provided for @addMemo.
  ///
  /// In ja, this message translates to:
  /// **'メモを追加'**
  String get addMemo;

  /// No description provided for @noMemoYet.
  ///
  /// In ja, this message translates to:
  /// **'メモはありません'**
  String get noMemoYet;

  /// No description provided for @markReviewed.
  ///
  /// In ja, this message translates to:
  /// **'確認済みにする'**
  String get markReviewed;

  /// No description provided for @markUnreviewed.
  ///
  /// In ja, this message translates to:
  /// **'未確認に戻す'**
  String get markUnreviewed;

  /// No description provided for @googleMapsAction.
  ///
  /// In ja, this message translates to:
  /// **'Google Mapsで確認'**
  String get googleMapsAction;

  /// No description provided for @streetViewAction.
  ///
  /// In ja, this message translates to:
  /// **'ストリートビューで確認'**
  String get streetViewAction;

  /// No description provided for @externalMapError.
  ///
  /// In ja, this message translates to:
  /// **'地図アプリを開けませんでした'**
  String get externalMapError;

  /// No description provided for @memoEditTitle.
  ///
  /// In ja, this message translates to:
  /// **'メモを編集'**
  String get memoEditTitle;

  /// No description provided for @memoHint.
  ///
  /// In ja, this message translates to:
  /// **'メモを入力...'**
  String get memoHint;

  /// No description provided for @permissionDenied.
  ///
  /// In ja, this message translates to:
  /// **'位置情報が許可されていません'**
  String get permissionDenied;

  /// No description provided for @permissionRequiredTitle.
  ///
  /// In ja, this message translates to:
  /// **'位置情報の許可が必要です'**
  String get permissionRequiredTitle;

  /// No description provided for @permissionRequiredDescription.
  ///
  /// In ja, this message translates to:
  /// **'設定から位置情報へのアクセスを許可してください。'**
  String get permissionRequiredDescription;

  /// No description provided for @openSettings.
  ///
  /// In ja, this message translates to:
  /// **'設定を開く'**
  String get openSettings;

  /// No description provided for @recordSuccess.
  ///
  /// In ja, this message translates to:
  /// **'現在地を記録しました'**
  String get recordSuccess;

  /// No description provided for @recordError.
  ///
  /// In ja, this message translates to:
  /// **'記録できませんでした: {error}'**
  String recordError(String error);

  /// No description provided for @quickModeReturningHome.
  ///
  /// In ja, this message translates to:
  /// **'Quick Modeを終了します'**
  String get quickModeReturningHome;

  /// No description provided for @quickModeRecordedCount.
  ///
  /// In ja, this message translates to:
  /// **'{count} 件記録'**
  String quickModeRecordedCount(int count);

  /// No description provided for @quickModeHoldToFinish.
  ///
  /// In ja, this message translates to:
  /// **'そのまま長押しで終了'**
  String get quickModeHoldToFinish;

  /// No description provided for @quickModeTapAnywhere.
  ///
  /// In ja, this message translates to:
  /// **'画面のどこでもタップで記録'**
  String get quickModeTapAnywhere;

  /// No description provided for @quickModeExitGuide.
  ///
  /// In ja, this message translates to:
  /// **'約1.5秒長押しで終了'**
  String get quickModeExitGuide;

  /// No description provided for @recordListTitle.
  ///
  /// In ja, this message translates to:
  /// **'記録一覧'**
  String get recordListTitle;

  /// No description provided for @deleteRecordTitle.
  ///
  /// In ja, this message translates to:
  /// **'この記録を削除しますか？'**
  String get deleteRecordTitle;

  /// No description provided for @deleteRecordDescription.
  ///
  /// In ja, this message translates to:
  /// **'削除した記録は元に戻せません。'**
  String get deleteRecordDescription;

  /// No description provided for @deleteSwipeGuide.
  ///
  /// In ja, this message translates to:
  /// **'左にスワイプして削除'**
  String get deleteSwipeGuide;

  /// No description provided for @emptyRecordListDescription.
  ///
  /// In ja, this message translates to:
  /// **'ホームから気になった場所を記録してみましょう。'**
  String get emptyRecordListDescription;

  /// No description provided for @mapTitle.
  ///
  /// In ja, this message translates to:
  /// **'マップ'**
  String get mapTitle;

  /// No description provided for @loading.
  ///
  /// In ja, this message translates to:
  /// **'読み込み中...'**
  String get loading;

  /// No description provided for @memoEmptyParenthesized.
  ///
  /// In ja, this message translates to:
  /// **'(メモなし)'**
  String get memoEmptyParenthesized;

  /// No description provided for @editMemoTooltip.
  ///
  /// In ja, this message translates to:
  /// **'メモを編集'**
  String get editMemoTooltip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
