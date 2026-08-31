part of 'interactor.dart';

/// [id]に一致するPinの確認状態を[status]へ更新する。
Future<void> _updatePinReviewStatus(
  Interactor interactor,
  int id,
  PinReviewStatus status,
) {
  return interactor._repository.updateReviewStatus(id, status);
}
