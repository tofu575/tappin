import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/repositories/pin_repository.dart';
import 'package:tappin/gateway/storage/pin_local_storage.dart';

class PinRepositoryImpl implements PinRepository {
  final PinLocalStorage storage;

  PinRepositoryImpl(this.storage);

  @override
  Future<List<Pin>> getPins() {
    return storage.fetchPins();
  }

  @override
  Future<int> savePin(Pin pin) {
    return storage.savePin(pin);
  }

  @override
  Future<void> deletePin(int id) {
    return storage.deletePin(id);
  }
}
