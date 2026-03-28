import 'package:geolocator/geolocator.dart';

import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/models/location/latitude.dart';
import 'package:tappin/domain/models/location/longitude.dart';
import 'package:tappin/domain/services/location_service.dart';

class GeolocatorLocationService implements LocationService {
  @override
  Future<Coordinate> fetchCurrentLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied ||
          requested == LocationPermission.deniedForever) {
        throw const LocationPermissionDeniedException();
      }
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return Coordinate(
      latitude: Latitude(position.latitude),
      longitude: Longitude(position.longitude),
    );
  }
}
