import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tappin/domain/interactor/interactor.dart';

/// Presentationへ構築済みInteractorを注入する境界Provider。
final interactorProvider = Provider<Interactor>((ref) {
  throw UnimplementedError('interactorProvider must be overridden');
});
