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

  MockLocationService.success(Coordinate coordinate)
      : _coordinate = coordinate,
        _exception = null;

  MockLocationService.denied()
      : _coordinate = null,
        _exception = const LocationPermissionDeniedException();

  MockLocationService.error(String message)
      : _coordinate = null,
        _exception = Exception(message);

  @override
  Future<Coordinate> fetchCurrentLocation() async {
    if (_exception != null) throw _exception;
    return _coordinate!;
  }
}
