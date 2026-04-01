import 'package:flutter/services.dart';

import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/gateway/storage/local_storage.dart';

class MethodChannelStorage implements LocalStorage {
  static const _channel = MethodChannel('com.example.tappin/native');

  @override
  Future<List<Pin>> fetchPins() async {
    final result = await _channel.invokeListMethod<Map<Object?, Object?>>('storage/getPins');
    if (result == null) return [];
    return result.map((raw) {
      final map = raw.map((k, v) => MapEntry(k.toString(), v));
      return Pin.fromMap(map.cast<String, dynamic>());
    }).toList();
  }

  @override
  Future<int> savePin(Pin pin) async {
    final id = await _channel.invokeMethod<Object>('storage/savePin', {
      'latitude': pin.latitude.value,
      'longitude': pin.longitude.value,
      'createdAt': pin.createdAt.value.millisecondsSinceEpoch,
    });
    return (id as num).toInt();
  }

  @override
  Future<void> deletePin(int id) async {
    await _channel.invokeMethod<void>('storage/deletePin', {'id': id});
  }
}
