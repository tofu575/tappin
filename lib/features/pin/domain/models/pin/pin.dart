import 'package:tappin/features/pin/domain/models/pin/latitude.dart';
import 'package:tappin/features/pin/domain/models/pin/longitude.dart';
import 'package:tappin/features/pin/domain/models/core/my_datetime.dart';

class Pin {
  final int? id;
  final Latitude latitude;
  final Longitude longitude;
  final MyDatetime createdAt;

  const Pin({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });
}
