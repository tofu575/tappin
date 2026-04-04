import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/models/location/latitude.dart';
import 'package:tappin/domain/models/location/longitude.dart';
import 'package:tappin/domain/services/location_service.dart';

class MethodChannelLocationService implements LocationService {
  static const _channel = MethodChannel('com.example.tappin/native');

  @override
  Future<Coordinate> fetchCurrentLocation() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isPermanentlyDenied) {
      throw const LocationPermissionPermanentlyDeniedException();
    }
    if (!status.isGranted) {
      throw const LocationPermissionDeniedException();
    }

    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('location/fetch');
      if (result == null) {
        throw const LocationPermissionDeniedException();
      }
      return Coordinate(
        latitude: Latitude(result['latitude'] as double),
        longitude: Longitude(result['longitude'] as double),
      );
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') throw const LocationPermissionDeniedException();
      rethrow;
    }
  }

  @override
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
