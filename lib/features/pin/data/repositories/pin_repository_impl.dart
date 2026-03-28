import '../../domain/entities/pin.dart';
import '../../domain/repositories/pin_repository.dart';
import '../datasources/pin_local_datasource.dart';
import '../models/pin_model.dart';

class PinRepositoryImpl implements PinRepository {
  final PinLocalDatasource datasource;

  PinRepositoryImpl(this.datasource);

  @override
  Future<List<Pin>> getPins() {
    return datasource.getPins();
  }

  @override
  Future<int> savePin(Pin pin) {
    return datasource.savePin(PinModel.fromEntity(pin));
  }

  @override
  Future<void> deletePin(int id) {
    return datasource.deletePin(id);
  }
}
