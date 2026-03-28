import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/repositories/pin_repository.dart';

class PinUseCase {
  final PinRepository _repository;

  PinUseCase(this._repository);

  Future<List<Pin>> fetchPins() => _repository.getPins();
  Future<int> savePin(Pin pin) => _repository.savePin(pin);
  Future<void> deletePin(int id) => _repository.deletePin(id);
}
