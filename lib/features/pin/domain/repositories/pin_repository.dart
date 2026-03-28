import 'package:tappin/features/pin/domain/models/pin/pin.dart';

abstract class PinRepository {
  Future<List<Pin>> getPins();
  Future<int> savePin(Pin pin);
  Future<void> deletePin(int id);
}
