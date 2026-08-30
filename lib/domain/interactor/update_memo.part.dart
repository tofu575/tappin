part of 'interactor.dart';

/// [id]に一致するPinのメモを[memo]へ更新する。
Future<void> _updateMemo(Interactor interactor, int id, Memo memo) {
  return interactor._repository.updateMemo(id, memo);
}
