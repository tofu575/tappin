import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/models/location/latitude.dart';
import 'package:tappin/domain/models/location/longitude.dart';
import 'package:tappin/domain/services/location_service.dart';

const _maximumCachedPositionAge = Duration(seconds: 30);
const _maximumCachedPositionAccuracyMeters = 50.0;
const _currentPositionTimeout = Duration(seconds: 8);

class GeolocatorLocationService implements LocationService {
  Position? _warmedPosition;
  Future<Position?>? _warmingPosition;

  @override
  Future<Coordinate> fetchCurrentLocation() async {
    await _ensurePermission();

    try {
      final warmedPosition = _warmedPosition;
      if (warmedPosition != null && _canReuse(warmedPosition)) {
        return _toCoordinate(warmedPosition);
      }

      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null && _canReuse(lastKnownPosition)) {
        _warmedPosition = lastKnownPosition;
        return _toCoordinate(lastKnownPosition);
      }

      final warmingPosition = _warmingPosition;
      final position = warmingPosition == null
          ? await _fetchFreshPosition()
          : await warmingPosition;
      if (position == null) {
        throw const LocationServiceDisabledException();
      }
      _warmedPosition = position;
      return _toCoordinate(position);
    } on PermissionDeniedException {
      throw const LocationPermissionDeniedException();
    }
  }

  @override
  Future<void> warmUp() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (!_isGranted(permission)) return;

      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null && _canReuse(lastKnownPosition)) {
        _warmedPosition = lastKnownPosition;
        return;
      }

      final warmingPosition = _fetchFreshPosition();
      _warmingPosition = warmingPosition;
      try {
        _warmedPosition = await warmingPosition;
      } finally {
        if (identical(_warmingPosition, warmingPosition)) {
          _warmingPosition = null;
        }
      }
    } on Exception {
      // 先行取得の失敗は記録ボタン押下時に改めて処理する。
    }
  }

  @override
  Future<void> openSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<void> _ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionPermanentlyDeniedException();
    }
    if (!_isGranted(permission)) {
      throw const LocationPermissionDeniedException();
    }
  }

  Future<Position> _fetchFreshPosition() {
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: _currentPositionTimeout,
      ),
    );
  }

  bool _canReuse(Position position) {
    final age = DateTime.now().difference(position.timestamp);
    final hasAcceptableAge =
        !age.isNegative && age <= _maximumCachedPositionAge;
    final hasAcceptableAccuracy =
        position.accuracy > 0 &&
        position.accuracy <= _maximumCachedPositionAccuracyMeters;
    return hasAcceptableAge && hasAcceptableAccuracy;
  }

  bool _isGranted(LocationPermission permission) {
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Coordinate _toCoordinate(Position position) {
    return Coordinate(
      latitude: Latitude(position.latitude),
      longitude: Longitude(position.longitude),
    );
  }
}
