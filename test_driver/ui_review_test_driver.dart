import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// 端末から受け取ったスクリーンショットをレビュー用ディレクトリへ保存する。
Future<void> main() async {
  final outputDirectory = Directory('screenshots/ui_review');
  await outputDirectory.create(recursive: true);

  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final image = File('${outputDirectory.path}/$name.png');
      await image.writeAsBytes(bytes, flush: true);
      return true;
    },
  );
}
