import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tappin/app.dart';
import 'package:tappin/config/app_env.dart';
import 'package:tappin/domain/usecases/use_case.dart';
import 'package:tappin/gateway/location/geolocator_location_service.dart';
import 'package:tappin/gateway/geocoding/native_geocoding_service.dart';
import 'package:tappin/gateway/storage/method_channel_storage.dart';
import 'package:tappin/gateway/overlay/native_overlay_service.dart';
import 'package:tappin/presentation/providers/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  AppEnv.initialize();

  await FMTCObjectBoxBackend().initialise();
  await FMTCStore('mapTiles').manage.create();

  // 初回起動時の説明表示フラグ
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('onboarding_v1') ?? false;

  runApp(
    ProviderScope(
      overrides: [
        useCaseProvider.overrideWithValue(UseCase(MethodChannelStorage())),
        locationServiceProvider.overrideWithValue(GeolocatorLocationService()),
        geocodingServiceProvider.overrideWithValue(NativeGeocodingService()),
        overlayServiceProvider.overrideWithValue(NativeOverlayService()),
      ],
      child: App(showOnboarding: !hasSeenOnboarding),
    ),
  );
}
