import 'package:model/model.dart';

abstract class GeocodingService {
  Future<String> fetchAddress(Coordinate coordinate);
}
