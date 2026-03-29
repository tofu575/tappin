import 'package:tappin/domain/models/location/latitude.dart';
import 'package:tappin/domain/models/location/longitude.dart';

class Coordinate {
  final Latitude latitude;
  final Longitude longitude;

  const Coordinate({required this.latitude, required this.longitude});

  @override
  bool operator ==(Object other) =>
      other is Coordinate &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}
