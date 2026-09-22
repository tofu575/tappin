import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:usecase/usecase.dart';

/// Presentationへ構築済みScreenAwakeGatewayを注入する境界Provider。
final screenAwakeProvider = Provider<ScreenAwakeGateway>((ref) {
  throw UnimplementedError('screenAwakeProvider must be overridden');
});
