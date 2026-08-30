import 'package:tappin/domain/interactor/interactor.dart';
import 'package:tappin/domain/repositories/repository.dart';
import 'package:tappin/domain/services/clock_gateway.dart';
import 'package:tappin/domain/services/external_map_gateway.dart';
import 'package:tappin/domain/services/geocoding_service.dart';
import 'package:tappin/domain/services/haptic_gateway.dart';
import 'package:tappin/domain/services/location_service.dart';
import 'package:tappin/domain/services/onboarding_gateway.dart';
import 'package:tappin/domain/services/overlay_service.dart';

import 'mock_clock_gateway.dart';
import 'mock_external_map_gateway.dart';
import 'mock_geocoding_service.dart';
import 'mock_haptic_gateway.dart';
import 'mock_location_service.dart';
import 'mock_onboarding_gateway.dart';
import 'mock_overlay_service.dart';
import 'mock_repository.dart';

/// 本番と同じ必須依存をMock Gatewayで満たしたInteractorを構築する。
Interactor buildTestInteractor({
  Repository? repository,
  LocationService? locationGateway,
  GeocodingService? geocodingGateway,
  OverlayService? overlayGateway,
  ClockGateway? clockGateway,
  HapticGateway? hapticGateway,
  ExternalMapGateway? externalMapGateway,
  OnboardingGateway? onboardingGateway,
}) {
  return Interactor(
    repository: repository ?? MockRipository(),
    locationGateway:
        locationGateway ?? MockLocationService.success(testCoordinate),
    geocodingGateway: geocodingGateway ?? MockGeocodingService(),
    overlayGateway: overlayGateway ?? MockOverlayService(),
    clockGateway: clockGateway ?? MockClockGateway(),
    hapticGateway: hapticGateway ?? MockHapticGateway(),
    externalMapGateway: externalMapGateway ?? MockExternalMapGateway(),
    onboardingGateway: onboardingGateway ?? MockOnboardingGateway(),
  );
}
