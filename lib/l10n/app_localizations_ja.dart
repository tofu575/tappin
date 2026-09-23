// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Tappin';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get save => '保存';

  @override
  String get edit => '編集';

  @override
  String errorWithDetail(String error) {
    return 'エラー: $error';
  }

  @override
  String get onboardingWelcomeTitle => 'Tappin へようこそ';

  @override
  String get onboardingWelcomeDescription =>
      '気になった場所を見つけたら、その場でワンタップ。\n場所と時間をすぐに記録できます。';

  @override
  String get onboardingReviewTitle => 'あとから場所を確認';

  @override
  String get onboardingReviewDescription =>
      '記録した場所は、あとから地図で確認できます。\n分かったことはメモに残せます。';

  @override
  String get onboardingQuickModeTitle => 'すばやく記録する Quick Mode';

  @override
  String get onboardingQuickModeDescription =>
      '画面のどこをタップしても現在地を記録できます。\n運転中は操作せず、同乗中など安全な状況でお使いください。';

  @override
  String get onboardingPrivacyTitle => '位置情報について';

  @override
  String get onboardingPrivacyDescription =>
      '位置情報は場所の記録にのみ使用します。\n記録したデータは端末内に保存され、外部には送信されません。';

  @override
  String get start => 'はじめる';

  @override
  String get next => '次へ';

  @override
  String get homeTagline => '気になった場所を記録しよう。';

  @override
  String get aboutTappin => 'Tappinについて';

  @override
  String get aboutDescription => 'Tappinの使い方や大切なお知らせをご覧いただけます。';

  @override
  String get officialWebsite => '公式サイト';

  @override
  String get officialWebsiteDescription => 'Tappinの紹介を見る';

  @override
  String get legalInformation => 'ポリシーと規約';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfService => '利用規約';

  @override
  String get opensInBrowser => 'ブラウザで開きます';

  @override
  String get webPageOpenError => 'ページを開けませんでした';

  @override
  String get record => '記録';

  @override
  String get pinHere => '場所を記録';

  @override
  String get history => '履歴';

  @override
  String unreviewedCountCompact(int count) {
    return '未確認 $count';
  }

  @override
  String get quickMode => 'Quick Mode';

  @override
  String get quickModeGuide => '画面全体をタップして、\nすばやく現在地を記録できます。\n運転者は操作しないでください。';

  @override
  String get startQuickMode => 'Quick Modeをはじめる';

  @override
  String get checkingPlace => '場所を確認中…';

  @override
  String get coordinateRecorded => '位置を記録しました';

  @override
  String get justPinned => '記録しました';

  @override
  String get historyTitle => '記録をふりかえる';

  @override
  String historyLoadError(String error) {
    return '記録を読み込めませんでした\n$error';
  }

  @override
  String get historyDescription => '記録した場所を、ひとつずつ確認できます。';

  @override
  String unreviewedCount(int count) {
    return '未確認  $count';
  }

  @override
  String reviewedCount(int count) {
    return '確認済み  $count';
  }

  @override
  String get noPinsTitle => 'まだ記録がありません';

  @override
  String get noPinsDescription => '気になった場所を記録してみましょう。';

  @override
  String get noUnreviewedTitle => '未確認の記録はありません';

  @override
  String get noReviewedTitle => '確認済みの記録はありません';

  @override
  String get noUnreviewedDescription => '新しく記録した場所がここに表示されます。';

  @override
  String get noReviewedDescription => '確認を終えた記録がここに表示されます。';

  @override
  String get reviewLater => 'あとで確認';

  @override
  String get reviewed => '確認済み';

  @override
  String get noMemo => 'メモなし';

  @override
  String get checkPlaceAction => '場所を確認する  →';

  @override
  String historyDate(String month, String day, String hour, String minute) {
    return '$month/$day $hour:$minute';
  }

  @override
  String get pinDetailTitle => '記録の詳細';

  @override
  String get deletePinTooltip => '記録を削除';

  @override
  String get deletePinTitle => 'この記録を削除しますか？';

  @override
  String get deletePinDescription => '削除した記録は元に戻せません。';

  @override
  String get reviewLaterRecord => '未確認の記録';

  @override
  String get checkingAddress => '住所を確認中…';

  @override
  String pinRecordedAt(
    String year,
    String month,
    String day,
    String hour,
    String minute,
  ) {
    return '$year/$month/$day $hour:$minute に記録';
  }

  @override
  String pinDateTime(
    String year,
    String month,
    String day,
    String hour,
    String minute,
  ) {
    return '$year/$month/$day $hour:$minute';
  }

  @override
  String get researchPlaceTitle => '場所を確認';

  @override
  String get externalMapDescription => '外部の地図アプリを開きます。';

  @override
  String get findingsTitle => 'メモ';

  @override
  String get addMemo => 'メモを追加';

  @override
  String get noMemoYet => 'メモはありません';

  @override
  String get markReviewed => '確認済みにする';

  @override
  String get markUnreviewed => '未確認に戻す';

  @override
  String get googleMapsAction => 'Google Mapsで確認';

  @override
  String get streetViewAction => 'ストリートビューで確認';

  @override
  String get externalMapError => '地図アプリを開けませんでした';

  @override
  String get memoEditTitle => 'メモを編集';

  @override
  String get memoHint => 'メモを入力...';

  @override
  String get permissionDenied => '位置情報が許可されていません';

  @override
  String get permissionRequiredTitle => '位置情報の許可が必要です';

  @override
  String get permissionRequiredDescription => '設定から位置情報へのアクセスを許可してください。';

  @override
  String get openSettings => '設定を開く';

  @override
  String get recordSuccess => '現在地を記録しました';

  @override
  String recordError(String error) {
    return '記録できませんでした: $error';
  }

  @override
  String get quickModeReturningHome => 'Quick Modeを終了します';

  @override
  String quickModeRecordedCount(int count) {
    return '$count 件記録';
  }

  @override
  String get quickModeHoldToFinish => 'そのまま長押しで終了';

  @override
  String get quickModeTapAnywhere => '画面のどこでもタップで記録';

  @override
  String get quickModeExitGuide => '約1.5秒長押しで終了';

  @override
  String get recordListTitle => '記録一覧';

  @override
  String get deleteRecordTitle => 'この記録を削除しますか？';

  @override
  String get deleteRecordDescription => '削除した記録は元に戻せません。';

  @override
  String get deleteSwipeGuide => '左にスワイプして削除';

  @override
  String get emptyRecordListDescription => 'ホームから気になった場所を記録してみましょう。';

  @override
  String get mapTitle => 'マップ';

  @override
  String get loading => '読み込み中...';

  @override
  String get memoEmptyParenthesized => '(メモなし)';

  @override
  String get editMemoTooltip => 'メモを編集';
}
