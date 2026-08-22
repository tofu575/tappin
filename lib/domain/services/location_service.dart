import 'package:tappin/domain/models/location/coordinate.dart';

abstract class LocationService {
  Future<Coordinate> fetchCurrentLocation();
  Future<void> warmUp();
  Future<void> openSettings();
}

class LocationPermissionDeniedException implements Exception {
  const LocationPermissionDeniedException();
}

class LocationPermissionPermanentlyDeniedException implements Exception {
  const LocationPermissionPermanentlyDeniedException();
}
