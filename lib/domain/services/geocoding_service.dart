import 'package:tappin/domain/models/location/coordinate.dart';

abstract class GeocodingService {
  Future<String> fetchAddress(Coordinate coordinate);
}
