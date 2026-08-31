// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'TapPin';

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
  String get onboardingWelcomeTitle => 'TapPin へようこそ';

  @override
  String get onboardingWelcomeDescription =>
      '気になった場所を、その場でワンタップ。\nあとで思い出すために、いったん預けられます。';

  @override
  String get onboardingReviewTitle => 'あとで、ゆっくり確認';

  @override
  String get onboardingReviewDescription =>
      '記録した場所は履歴にまとまります。\n地図で調べて、分かったことをメモできます。';

  @override
  String get onboardingQuickModeTitle => '移動中は Quick Mode';

  @override
  String get onboardingQuickModeDescription =>
      '画面のどこをタップしても場所を記録。\n車でも電車でも、歩いているときでも使えます。';

  @override
  String get onboardingPrivacyTitle => '位置情報について';

  @override
  String get onboardingPrivacyDescription =>
      '位置情報はピンの記録にのみ使用します。\nデータはすべてお使いの端末内に保存され、外部に送信されません。';

  @override
  String get start => 'はじめる';

  @override
  String get next => '次へ';

  @override
  String get homeTagline => '気になった場所を、ここに預けよう。';

  @override
  String get record => '記録';

  @override
  String get pinHere => 'ここに留める';

  @override
  String get history => '履歴';

  @override
  String unreviewedCountCompact(int count) {
    return '未確認 $count';
  }

  @override
  String get quickMode => 'Quick Mode';

  @override
  String get quickModeGuide => '画面のどこをタップしても、\n気になった場所をすぐ記録できます。';

  @override
  String get startQuickMode => 'Quick Modeをはじめる';

  @override
  String get checkingPlace => '場所を確認中…';

  @override
  String get coordinateRecorded => '記録した座標を預かりました';

  @override
  String get justPinned => 'いま預けました';

  @override
  String get historyTitle => '記録をふりかえる';

  @override
  String historyLoadError(String error) {
    return '記録を読み込めませんでした\n$error';
  }

  @override
  String get historyDescription => '気になった場所を、ひとつずつ確かめよう。';

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
  String get noPinsDescription => 'ホームから、気になった場所を預けてみましょう。';

  @override
  String get noUnreviewedTitle => 'いま確認する記録はありません';

  @override
  String get noReviewedTitle => '確認済みの記録はまだありません';

  @override
  String get noUnreviewedDescription => '気になった場所は、ホームから気軽に預けられます。';

  @override
  String get noReviewedDescription => '確認を終えた記録がここに残ります。';

  @override
  String get reviewLater => 'あとで見る';

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
  String get reviewLaterRecord => 'あとで見るための記録';

  @override
  String get checkingAddress => '住所を確認しています…';

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
  String get researchPlaceTitle => 'この場所を調べる';

  @override
  String get externalMapDescription => '外部の地図アプリが開きます。';

  @override
  String get findingsTitle => '分かったこと';

  @override
  String get addMemo => 'メモを追加';

  @override
  String get noMemoYet => 'まだメモはありません';

  @override
  String get markReviewed => '確認できた';

  @override
  String get markUnreviewed => '未確認に戻す';

  @override
  String get googleMapsAction => 'Google Mapsで場所を確認';

  @override
  String get streetViewAction => 'ストリートビューで周辺を見る';

  @override
  String get externalMapError => '地図アプリを開けませんでした';

  @override
  String get memoEditTitle => 'メモを編集';

  @override
  String get memoHint => 'メモを入力...';

  @override
  String get permissionDenied => '位置情報が許可されませんでした';

  @override
  String get permissionRequiredTitle => '位置情報の許可が必要です';

  @override
  String get permissionRequiredDescription => '設定から位置情報へのアクセスを許可してください';

  @override
  String get openSettings => '設定を開く';

  @override
  String get recordSuccess => '現在地を記録しました';

  @override
  String recordError(String error) {
    return 'エラーが発生しました: $error';
  }

  @override
  String get quickModeReturningHome => 'ホームへ戻ります';

  @override
  String quickModeRecordedCount(int count) {
    return '$count 件記録済み';
  }

  @override
  String get quickModeHoldToFinish => 'そのまま長押しで終了';

  @override
  String get quickModeTapAnywhere => '画面のどこでもタップで記録';

  @override
  String get quickModeExitGuide => '終了するには約1.5秒長押し';

  @override
  String get recordListTitle => '記録一覧';

  @override
  String get deleteRecordTitle => '削除しますか？';

  @override
  String get deleteRecordDescription => 'この記録を削除します。元に戻せません。';

  @override
  String get deleteSwipeGuide => '記録を左にスワイプすると削除できます';

  @override
  String get emptyRecordListDescription => 'ホーム画面の記録ボタンを押して\n現在地を保存しましょう';

  @override
  String get mapTitle => 'マップ';

  @override
  String get loading => '読み込み中...';

  @override
  String get memoEmptyParenthesized => '(メモなし)';

  @override
  String get editMemoTooltip => 'メモを編集';
}
