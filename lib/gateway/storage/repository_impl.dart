import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/repositories/repository.dart';
import 'package:tappin/gateway/storage/local_storage.dart';

class RepositoryImpl implements Repository {
  final LocalStorage storage;

  RepositoryImpl(this.storage);

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
