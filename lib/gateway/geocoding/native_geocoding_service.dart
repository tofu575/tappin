import 'package:geocoding/geocoding.dart';

import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/services/geocoding_service.dart';

class NativeGeocodingService implements GeocodingService {
  @override
  Future<String> fetchAddress(Coordinate coordinate) async {
    final placemarks = await placemarkFromCoordinates(
      coordinate.latitude.value,
      coordinate.longitude.value,
    );
    if (placemarks.isEmpty) {
      return '${coordinate.latitude.value}, ${coordinate.longitude.value}';
    }
    final p = placemarks.first;
    final parts = [p.administrativeArea, p.locality]
        .where((s) => s != null && s.isNotEmpty)
        .toList();
    return parts.isNotEmpty
        ? parts.join('')
        : '${coordinate.latitude.value}, ${coordinate.longitude.value}';
  }
}
