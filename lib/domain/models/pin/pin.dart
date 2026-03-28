import 'package:tappin/domain/models/location/latitude.dart';
import 'package:tappin/domain/models/location/longitude.dart';
import 'package:tappin/domain/models/core/my_datetime.dart';

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

  factory Pin.fromMap(Map<String, dynamic> map) {
    return Pin(
      id: map['id'] as int?,
      latitude: Latitude(map['latitude'] as double),
      longitude: Longitude(map['longitude'] as double),
      createdAt: MyDatetime(
        DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'latitude': latitude.value,
      'longitude': longitude.value,
      'created_at': createdAt.value.millisecondsSinceEpoch,
    };
  }
}
