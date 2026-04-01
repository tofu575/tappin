import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tappin/app.dart';
import 'package:tappin/domain/usecases/use_case.dart';
import 'package:tappin/gateway/location/method_channel_location_service.dart';
import 'package:tappin/gateway/geocoding/native_geocoding_service.dart';
import 'package:tappin/gateway/storage/method_channel_storage.dart';
import 'package:tappin/gateway/widget/app_home_widget_service.dart';
import 'package:tappin/presentation/providers/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      overrides: [
        useCaseProvider.overrideWithValue(UseCase(MethodChannelStorage())),
        locationServiceProvider.overrideWithValue(MethodChannelLocationService()),
        geocodingServiceProvider.overrideWithValue(NativeGeocodingService()),
        homeWidgetServiceProvider.overrideWithValue(AppHomeWidgetService()),
      ],
      child: const App(),
    ),
  );
}
