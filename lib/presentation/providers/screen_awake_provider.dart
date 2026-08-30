import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tappin/domain/services/screen_awake_gateway.dart';

/// Presentationへ構築済みScreenAwakeGatewayを注入する境界Provider。
final screenAwakeProvider = Provider<ScreenAwakeGateway>((ref) {
  throw UnimplementedError('screenAwakeProvider must be overridden');
});
