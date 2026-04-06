import 'package:tappin/config/tile_url_template.dart';

class AppEnv {
  AppEnv._();

  static late final TileUrlTemplate tileUrlTemplate;

  static void initialize() {
    tileUrlTemplate = TileUrlTemplate();
  }
}
