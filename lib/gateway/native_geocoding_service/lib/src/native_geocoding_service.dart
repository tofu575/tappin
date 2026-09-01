import 'package:geocoding/geocoding.dart';

import 'package:model/model.dart';
import 'package:usecase/usecase.dart';

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
    // 都道府県と市区町村を結合して大まかな住所とする
    final parts = [
      p.administrativeArea,
      p.locality,
    ].where((s) => s != null && s.isNotEmpty).toList();
    return parts.isNotEmpty
        ? parts.join('')
        : '${coordinate.latitude.value}, ${coordinate.longitude.value}';
  }
}
