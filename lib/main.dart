import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_haptic_gateway/flutter_haptic_gateway.dart';
import 'package:geolocator_location_service/geolocator_location_service.dart';
import 'package:method_channel_storage/method_channel_storage.dart';
import 'package:native_geocoding_service/native_geocoding_service.dart';
import 'package:shared_preferences_onboarding_gateway/shared_preferences_onboarding_gateway.dart';
import 'package:system_clock_gateway/system_clock_gateway.dart';
import 'package:url_launcher_external_map_gateway/url_launcher_external_map_gateway.dart';
import 'package:usecase/usecase.dart';
import 'package:wakelock_screen_awake_gateway/wakelock_screen_awake_gateway.dart';

import 'package:tappin/app.dart';
import 'package:tappin/presentation/providers/interactor_provider.dart';
import 'package:tappin/presentation/providers/screen_awake_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final onboardingGateway = await SharedPreferencesOnboardingGateway.create();
  final interactor = Interactor(
    repository: MethodChannelStorage(),
    locationGateway: GeolocatorLocationService(),
    geocodingGateway: NativeGeocodingService(),
    clockGateway: const SystemClockGateway(),
    hapticGateway: const FlutterHapticGateway(),
    externalMapGateway: const UrlLauncherExternalMapGateway(),
    onboardingGateway: onboardingGateway,
  );

  runApp(
    ProviderScope(
      overrides: [
        interactorProvider.overrideWithValue(interactor),
        screenAwakeProvider.overrideWithValue(
          const WakelockScreenAwakeGateway(),
        ),
      ],
      child: App(showOnboarding: !interactor.hasCompletedOnboarding()),
    ),
  );
}
