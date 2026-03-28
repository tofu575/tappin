import '../entities/pin.dart';

abstract class PinRepository {
  Future<List<Pin>> getPins();
  Future<int> savePin(Pin pin);
  Future<void> deletePin(int id);
}
