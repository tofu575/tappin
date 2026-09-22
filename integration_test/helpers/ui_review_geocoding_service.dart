import 'package:model/model.dart';
import 'package:usecase/usecase.dart';

/// UIレビュー用の座標へ固定住所を返し、ネットワーク参照を避ける。
class UiReviewGeocodingService implements GeocodingService {
  static final _addresses = {
    (35.681236, 139.767125): '東京都千代田区丸の内 東京駅',
    (35.658581, 139.745433): '東京都港区芝公園 東京タワー',
    (35.710063, 139.8107): '東京都墨田区押上',
    (35.676398, 139.699326): '東京都渋谷区神宮前',
  };

  @override
  Future<String> fetchAddress(Coordinate coordinate) async {
    final key = (coordinate.latitude.value, coordinate.longitude.value);
    return _addresses[key] ?? '東京都千代田区丸の内 東京駅';
  }
}
