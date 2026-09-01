import 'package:model/model.dart';
import 'package:usecase/usecase.dart';

class MockGeocodingService implements GeocodingService {
  final String stubbedAddress;

  MockGeocodingService({this.stubbedAddress = '東京都渋谷区道玄坂'});

  @override
  Future<String> fetchAddress(Coordinate coordinate) async {
    return stubbedAddress;
  }
}
