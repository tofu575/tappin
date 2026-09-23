import 'package:geocoding/geocoding.dart';

import 'package:model/model.dart';
import 'package:usecase/usecase.dart';

/// 端末のジオコーディング機能から座標に対応する住所を取得する。
class NativeGeocodingService implements GeocodingService {
  final Geocoding _geocoding = Geocoding();

  @override
  Future<String> fetchAddress(Coordinate coordinate) async {
    final placemarks = await _geocoding.placemarkFromCoordinates(
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
