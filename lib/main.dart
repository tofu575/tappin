import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tappin/app.dart';
import 'package:tappin/config/app_env.dart';
import 'package:tappin/domain/interactor/interactor.dart';
import 'package:tappin/gateway/device/flutter_haptic_gateway.dart';
import 'package:tappin/gateway/device/system_clock_gateway.dart';
import 'package:tappin/gateway/external_map/url_launcher_external_map_gateway.dart';
import 'package:tappin/gateway/geocoding/native_geocoding_service.dart';
import 'package:tappin/gateway/location/geolocator_location_service.dart';
import 'package:tappin/gateway/onboarding/shared_preferences_onboarding_gateway.dart';
import 'package:tappin/gateway/overlay/native_overlay_service.dart';
import 'package:tappin/gateway/storage/method_channel_storage.dart';
import 'package:tappin/presentation/providers/interactor_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  AppEnv.initialize();

  await FMTCObjectBoxBackend().initialise();
  await FMTCStore('mapTiles').manage.create();

  final preferences = await SharedPreferences.getInstance();
  final interactor = Interactor(
    repository: MethodChannelStorage(),
    locationGateway: GeolocatorLocationService(),
    geocodingGateway: NativeGeocodingService(),
    overlayGateway: NativeOverlayService(),
    clockGateway: const SystemClockGateway(),
    hapticGateway: const FlutterHapticGateway(),
    externalMapGateway: const UrlLauncherExternalMapGateway(),
    onboardingGateway: SharedPreferencesOnboardingGateway(preferences),
  );

  runApp(
    ProviderScope(
      overrides: [interactorProvider.overrideWithValue(interactor)],
      child: App(showOnboarding: !interactor.hasCompletedOnboarding()),
    ),
  );
}
