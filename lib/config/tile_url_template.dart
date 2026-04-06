import 'package:flutter_dotenv/flutter_dotenv.dart';

class TileUrlTemplate {
  TileUrlTemplate._fromString(String value) : _value = value;

  factory TileUrlTemplate() {
    final url = dotenv.env['TILE_URL_TEMPLATE'];
    if (url == null || url.isEmpty) {
      throw StateError('環境変数 TILE_URL_TEMPLATE が設定されていません');
    }
    if (!url.startsWith('https://') && !url.startsWith('http://')) {
      throw StateError('TILE_URL_TEMPLATE が有効なURL形式ではありません: $url');
    }
    return TileUrlTemplate._fromString(url);
  }

  // https://{s}.basemaps.cartocdn.com/... の {s} という部分が RFC的に不正なホスト名 として扱われる
  // Uri.parse で hasAuthority が false になるか、パース後の toString() でURLが壊れる可能性があるため、単純なStringとして保持する
  final String _value;

  String get value => _value;
}
