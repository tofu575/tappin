part of 'interactor.dart';

/// [id]に一致するPinをGatewayから削除する。
Future<void> _deletePin(Interactor interactor, int id) {
  return interactor._repository.deletePin(id);
}
