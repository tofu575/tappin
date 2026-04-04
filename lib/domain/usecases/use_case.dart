import 'package:tappin/domain/models/pin/memo.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/repositories/repository.dart';

class UseCase {
  final Repository _repository;

  UseCase(this._repository);

  Future<List<Pin>> fetchPins() => _repository.getPins();
  Future<int> savePin(Pin pin) => _repository.savePin(pin);
  Future<void> deletePin(int id) => _repository.deletePin(id);
  Future<void> updateMemo(int id, Memo memo) => _repository.updateMemo(id, memo);
}
