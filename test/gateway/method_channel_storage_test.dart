import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:method_channel_storage/method_channel_storage.dart';

/// Android・iOSと共有するMethodChannel名で保存処理を呼び出すことを検証する。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.tofu575.tappin/native');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => <Object?>[]);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('新しいアプリIDのチャンネルから保存済みPinを取得する', () async {
    final pins = await MethodChannelStorage().getPins();

    expect(pins, isEmpty);
  });
}
