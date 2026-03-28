import 'package:tappin/features/pin/domain/entities/pin.dart';
import 'package:tappin/features/pin/domain/repositories/pin_repository.dart';
import 'package:tappin/features/pin/data/storages/pin_local_storage.dart';
import 'package:tappin/features/pin/data/models/pin_model.dart';

class PinRepositoryImpl implements PinRepository {
  final PinLocalStorage storage;

  PinRepositoryImpl(this.storage);

  @override
  Future<List<Pin>> getPins() {
    return storage.fetchPins();
  }

  @override
  Future<int> savePin(Pin pin) {
    return storage.savePin(PinModel.fromEntity(pin));
  }

  @override
  Future<void> deletePin(int id) {
    return storage.deletePin(id);
  }
}
