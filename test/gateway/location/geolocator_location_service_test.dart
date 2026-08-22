import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:tappin/gateway/location/geolocator_location_service.dart';

Position _buildPosition({
  required DateTime timestamp,
  double accuracy = 10,
  double latitude = 35.6812,
  double longitude = 139.7671,
}) {
  return Position(
    longitude: longitude,
    latitude: latitude,
    timestamp: timestamp,
    accuracy: accuracy,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}

class _FakeGeolocatorPlatform extends GeolocatorPlatform {
  LocationPermission permission = LocationPermission.whileInUse;
  LocationPermission requestedPermission = LocationPermission.whileInUse;
  Position? lastKnownPosition;
  Position currentPosition = _buildPosition(timestamp: DateTime.now());
  int currentPositionCalls = 0;
  int permissionRequestCalls = 0;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async {
    permissionRequestCalls++;
    return requestedPermission;
  }

  @override
  Future<Position?> getLastKnownPosition({
    bool forceLocationManager = false,
  }) async {
    return lastKnownPosition;
  }

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    currentPositionCalls++;
    return currentPosition;
  }

  @override
  Future<bool> openAppSettings() async => true;
}

void main() {
  late GeolocatorPlatform originalPlatform;
  late _FakeGeolocatorPlatform fakePlatform;

  setUp(() {
    originalPlatform = GeolocatorPlatform.instance;
    fakePlatform = _FakeGeolocatorPlatform();
    GeolocatorPlatform.instance = fakePlatform;
  });

  tearDown(() {
    GeolocatorPlatform.instance = originalPlatform;
  });

  test('30秒以内で精度が十分な直近位置を再利用する', () async {
    fakePlatform.lastKnownPosition = _buildPosition(
      timestamp: DateTime.now().subtract(const Duration(seconds: 20)),
      latitude: 34.6937,
      longitude: 135.5023,
    );

    final coordinate = await GeolocatorLocationService().fetchCurrentLocation();

    expect(coordinate.latitude.value, 34.6937);
    expect(coordinate.longitude.value, 135.5023);
    expect(fakePlatform.currentPositionCalls, 0);
  });

  test('直近位置が古い場合は新しく測位する', () async {
    fakePlatform.lastKnownPosition = _buildPosition(
      timestamp: DateTime.now().subtract(const Duration(seconds: 31)),
    );

    await GeolocatorLocationService().fetchCurrentLocation();

    expect(fakePlatform.currentPositionCalls, 1);
  });

  test('直近位置の精度が低い場合は新しく測位する', () async {
    fakePlatform.lastKnownPosition = _buildPosition(
      timestamp: DateTime.now(),
      accuracy: 51,
    );

    await GeolocatorLocationService().fetchCurrentLocation();

    expect(fakePlatform.currentPositionCalls, 1);
  });

  test('権限が未決定のときはボタン押下時に要求する', () async {
    fakePlatform.permission = LocationPermission.denied;

    await GeolocatorLocationService().fetchCurrentLocation();

    expect(fakePlatform.permissionRequestCalls, 1);
  });

  test('先行取得では位置情報権限を要求しない', () async {
    fakePlatform.permission = LocationPermission.denied;

    await GeolocatorLocationService().warmUp();

    expect(fakePlatform.permissionRequestCalls, 0);
    expect(fakePlatform.currentPositionCalls, 0);
  });
}
