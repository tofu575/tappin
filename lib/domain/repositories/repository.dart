import 'package:tappin/domain/models/pin/memo.dart';
import 'package:tappin/domain/models/pin/pin.dart';

abstract class Repository {
  Future<List<Pin>> getPins();
  Future<int> savePin(Pin pin);
  Future<void> deletePin(int id);
  Future<void> updateMemo(int id, Memo memo);
}
