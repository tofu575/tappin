import 'package:flutter/foundation.dart';

/// RecordFeedbackの成功・失敗フラッシュを起動する。
class RecordFeedbackController {
  VoidCallback? _showFlash;
  VoidCallback? _showFailureFlash;

  /// 成功フラッシュを即時表示する。
  void showSuccess() {
    _showFlash?.call();
  }

  /// 失敗色のフラッシュを即時表示する。
  void showFailure() {
    _showFailureFlash?.call();
  }

  /// [showFlash]を現在表示中のRecordFeedbackへ接続する。
  void attach(VoidCallback showFlash, VoidCallback showFailureFlash) {
    _showFlash = showFlash;
    _showFailureFlash = showFailureFlash;
  }

  /// 破棄されるRecordFeedbackとの接続だけを解除する。
  void detach(VoidCallback showFlash, VoidCallback showFailureFlash) {
    if (_showFlash == showFlash) _showFlash = null;
    if (_showFailureFlash == showFailureFlash) _showFailureFlash = null;
  }
}
