import 'package:tappin/domain/models/location/coordinate.dart';

abstract class LocationService {
  Future<Coordinate> fetchCurrentLocation();
}

class LocationPermissionDeniedException implements Exception {
  const LocationPermissionDeniedException();
}
