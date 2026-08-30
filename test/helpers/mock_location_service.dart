import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/models/location/latitude.dart';
import 'package:tappin/domain/models/location/longitude.dart';
import 'package:tappin/domain/services/location_service.dart';

final testCoordinate = Coordinate(
  latitude: Latitude(35.6812),
  longitude: Longitude(139.7671),
);

class MockLocationService implements LocationService {
  final Coordinate? _coordinate;
  final Exception? _exception;
  int warmUpCount = 0;
  int fetchCurrentLocationCount = 0;

  MockLocationService.success(Coordinate coordinate)
    : _coordinate = coordinate,
      _exception = null;

  MockLocationService.denied()
    : _coordinate = null,
      _exception = const LocationPermissionDeniedException();

  MockLocationService.permanentlyDenied()
    : _coordinate = null,
      _exception = const LocationPermissionPermanentlyDeniedException();

  MockLocationService.error(String message)
    : _coordinate = null,
      _exception = Exception(message);

  @override
  Future<Coordinate> fetchCurrentLocation() async {
    fetchCurrentLocationCount++;
    if (_exception != null) throw _exception;
    return _coordinate!;
  }

  @override
  Future<void> openSettings() async {}

  @override
  Future<void> warmUp() async {
    warmUpCount++;
  }
}
