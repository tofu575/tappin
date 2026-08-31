import 'package:tappin/domain/models/pin/memo.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/models/pin/pin_review_status.dart';

/// Pinの保存・取得・更新を端末ストレージへ委譲する境界。
abstract class Repository {
  Future<List<Pin>> getPins();
  Future<int> savePin(Pin pin);
  Future<void> deletePin(int id);
  Future<void> updateMemo(int id, Memo memo);
  Future<void> updateReviewStatus(int id, PinReviewStatus status);
}
