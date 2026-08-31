import 'package:flutter_test/flutter_test.dart';

import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/models/pin/pin_review_status.dart';

/// Pinの保存形式と明示的な確認状態の相互変換を検証する。
void main() {
  test('reviewed=1を確認済みとして復元する', () {
    final pin = Pin.fromMap({
      'id': 1,
      'latitude': 35.6812,
      'longitude': 139.7671,
      'created_at': 1720000000000,
      'memo': '',
      'reviewed': 1,
    });

    expect(pin.reviewStatus, PinReviewStatus.reviewed);
    expect(pin.toMap()['reviewed'], 1);
  });

  test('既存形式にreviewedがなければ未確認として復元する', () {
    final pin = Pin.fromMap({
      'id': 1,
      'latitude': 35.6812,
      'longitude': 139.7671,
      'created_at': 1720000000000,
      'memo': '',
    });

    expect(pin.reviewStatus, PinReviewStatus.unreviewed);
  });
}
