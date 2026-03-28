import 'package:tappin/domain/models/location/latitude.dart';
import 'package:tappin/domain/models/location/longitude.dart';

class Coordinate {
  final Latitude latitude;
  final Longitude longitude;

  const Coordinate({required this.latitude, required this.longitude});
}
