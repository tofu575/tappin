import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import 'package:tappin/app.dart';
import 'package:tappin/domain/usecases/use_case.dart';
import 'package:tappin/gateway/location/geolocator_location_service.dart';
import 'package:tappin/gateway/geocoding/native_geocoding_service.dart';
import 'package:tappin/gateway/storage/local_storage.dart';
import 'package:tappin/gateway/widget/app_home_widget_service.dart';
import 'package:tappin/gateway/storage/repository_impl.dart';
import 'package:tappin/home_widget_callback.dart';
import 'package:tappin/presentation/providers/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HomeWidget.registerInteractivityCallback(homeWidgetBackgroundCallback);

  final storage = await SQLiteStorage.open();
  final repository = RepositoryImpl(storage);

  runApp(
    ProviderScope(
      overrides: [
        useCaseProvider.overrideWithValue(UseCase(repository)),
        locationServiceProvider.overrideWithValue(GeolocatorLocationService()),
        geocodingServiceProvider.overrideWithValue(NativeGeocodingService()),
        homeWidgetServiceProvider.overrideWithValue(AppHomeWidgetService()),
      ],
      child: const App(),
    ),
  );
}
