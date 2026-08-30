import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/models/pin/memo.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/repositories/repository.dart';
import 'package:tappin/domain/services/clock_gateway.dart';
import 'package:tappin/domain/services/external_map_destination.dart';
import 'package:tappin/domain/services/external_map_gateway.dart';
import 'package:tappin/domain/services/geocoding_service.dart';
import 'package:tappin/domain/services/haptic_gateway.dart';
import 'package:tappin/domain/services/location_service.dart';
import 'package:tappin/domain/services/onboarding_gateway.dart';
import 'package:tappin/domain/services/overlay_service.dart';

part 'complete_onboarding.part.dart';
part 'delete_pin.part.dart';
part 'fetch_address.part.dart';
part 'fetch_current_location.part.dart';
part 'fetch_pins.part.dart';
part 'has_completed_onboarding.part.dart';
part 'hide_overlay.part.dart';
part 'open_external_map.part.dart';
part 'open_location_settings.part.dart';
part 'record_current_location.part.dart';
part 'show_overlay.part.dart';
part 'update_memo.part.dart';
part 'warm_up_location.part.dart';

/// Presentationへアプリケーションの操作単位を提供する。
class Interactor {
  /// 永続化と端末機能のGatewayをすべて必須依存として受け取る。
  Interactor({
    required Repository repository,
    required LocationService locationGateway,
    required GeocodingService geocodingGateway,
    required OverlayService overlayGateway,
    required ClockGateway clockGateway,
    required HapticGateway hapticGateway,
    required ExternalMapGateway externalMapGateway,
    required OnboardingGateway onboardingGateway,
  }) : _repository = repository,
       _locationGateway = locationGateway,
       _geocodingGateway = geocodingGateway,
       _overlayGateway = overlayGateway,
       _clockGateway = clockGateway,
       _hapticGateway = hapticGateway,
       _externalMapGateway = externalMapGateway,
       _onboardingGateway = onboardingGateway;

  final Repository _repository;
  final LocationService _locationGateway;
  final GeocodingService _geocodingGateway;
  final OverlayService _overlayGateway;
  final ClockGateway _clockGateway;
  final HapticGateway _hapticGateway;
  final ExternalMapGateway _externalMapGateway;
  final OnboardingGateway _onboardingGateway;
  DateTime? _lastRecordTime;
  bool _isRecording = false;

  /// 保存済みPinを取得する。
  Future<List<Pin>> fetchPins() => _fetchPins(this);

  /// 現在地を取得してPinを保存し、成功ハプティクスを開始する。
  Future<Pin?> recordCurrentLocation() => _recordCurrentLocation(this);

  /// [id]のPinを削除する。
  Future<void> deletePin(int id) => _deletePin(this, id);

  /// [id]のPinのメモを[memo]へ更新する。
  Future<void> updateMemo(int id, Memo memo) => _updateMemo(this, id, memo);

  /// 位置情報Gatewayを事前準備する。
  Future<void> warmUpLocation() => _warmUpLocation(this);

  /// 端末の現在地を取得する。
  Future<Coordinate> fetchCurrentLocation() => _fetchCurrentLocation(this);

  /// 端末の位置情報設定画面を開く。
  Future<void> openLocationSettings() => _openLocationSettings(this);

  /// [coordinate]の住所を取得する。
  Future<String> fetchAddress(Coordinate coordinate) =>
      _fetchAddress(this, coordinate);

  /// ネイティブOverlayを表示する。
  Future<void> showOverlay() => _showOverlay(this);

  /// ネイティブOverlayを非表示にする。
  Future<void> hideOverlay() => _hideOverlay(this);

  /// [coordinate]を外部地図の[destination]で開く。
  Future<void> openExternalMap(
    Coordinate coordinate,
    ExternalMapDestination destination,
  ) => _openExternalMap(this, coordinate, destination);

  /// Onboardingが完了済みか返す。
  bool hasCompletedOnboarding() => _hasCompletedOnboarding(this);

  /// Onboardingを完了済みとして保存する。
  Future<void> completeOnboarding() => _completeOnboarding(this);
}
