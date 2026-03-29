import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';

import 'package:tappin/domain/models/core/my_datetime.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/services/location_service.dart';
import 'package:tappin/gateway/geocoding/native_geocoding_service.dart';
import 'package:tappin/gateway/location/geolocator_location_service.dart';
import 'package:tappin/gateway/storage/local_storage.dart';
import 'package:tappin/gateway/storage/repository_impl.dart';

const _widgetAndroidName = 'TappinWidgetProvider';

@pragma('vm:entry-point')
Future<void> homeWidgetBackgroundCallback(Uri? uri) async {
  if (uri?.host != 'record') return;

  WidgetsFlutterBinding.ensureInitialized();

  // アニメーションを開始しておく（完了時に completer を complete して停止）
  final completer = Completer<void>();

  Future<void> _startRecordingAnimation() async {
    final frames = ['record_0', 'record_1', 'record_2', 'record_3'];
    var i = 0;
    try {
      while (!completer.isCompleted) {
        await HomeWidget.saveWidgetData<String>('state', frames[i]);
        await HomeWidget.updateWidget(androidName: _widgetAndroidName);
        i = (i + 1) % frames.length;
        await Future.delayed(const Duration(milliseconds: 250));
      }
    } catch (_) {
      // アニメーション更新失敗は無視して終了
    }
  }

  // 最初にアニメーションを "loading" 状態で開始
  await HomeWidget.saveWidgetData<String>('state', 'loading');
  await HomeWidget.updateWidget(androidName: _widgetAndroidName);
  final animFuture = _startRecordingAnimation();

  try {
    final coordinate = await GeolocatorLocationService().fetchCurrentLocation();

    final storage = await SQLiteStorage.open();
    final pin = Pin(
      latitude: coordinate.latitude,
      longitude: coordinate.longitude,
      createdAt: MyDatetime(DateTime.now()),
    );
    await RepositoryImpl(storage).savePin(pin);

    final address = await NativeGeocodingService().fetchAddress(coordinate);
    final now = pin.createdAt.value;
    final timestamp =
        '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // 処理完了：アニメーション停止して最終データを保存
    if (!completer.isCompleted) completer.complete();
    await animFuture;

    await HomeWidget.saveWidgetData<String>('state', 'idle');
    await HomeWidget.saveWidgetData<String>('address', address);
    await HomeWidget.saveWidgetData<String>('timestamp', timestamp);
    await HomeWidget.updateWidget(androidName: _widgetAndroidName);
  } on LocationPermissionDeniedException {
    if (!completer.isCompleted) completer.complete();
    await animFuture;

    await HomeWidget.saveWidgetData<String>('state', 'error');
    await HomeWidget.saveWidgetData<String>('address', '位置情報の許可が必要です');
    await HomeWidget.updateWidget(androidName: _widgetAndroidName);
  } catch (_) {
    if (!completer.isCompleted) completer.complete();
    await animFuture;

    await HomeWidget.saveWidgetData<String>('state', 'error');
    await HomeWidget.saveWidgetData<String>('address', 'エラーが発生しました');
    await HomeWidget.updateWidget(androidName: _widgetAndroidName);
  }
}
// ...existing code...