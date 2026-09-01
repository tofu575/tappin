import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:usecase/usecase.dart';

/// Presentationへ構築済みInteractorを注入する境界Provider。
final interactorProvider = Provider<Interactor>((ref) {
  throw UnimplementedError('interactorProvider must be overridden');
});
