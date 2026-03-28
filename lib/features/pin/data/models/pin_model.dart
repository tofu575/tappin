import 'package:tappin/features/pin/domain/models/pin/pin.dart';
import 'package:tappin/features/pin/domain/models/pin/latitude.dart';
import 'package:tappin/features/pin/domain/models/pin/longitude.dart';
import 'package:tappin/features/pin/domain/models/core/my_datetime.dart';

class PinModel extends Pin {
  const PinModel({
    super.id,
    required super.latitude,
    required super.longitude,
    required super.createdAt,
  });

  factory PinModel.fromMap(Map<String, dynamic> map) {
    return PinModel(
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

  factory PinModel.fromEntity(Pin pin) {
    return PinModel(
      id: pin.id,
      latitude: pin.latitude,
      longitude: pin.longitude,
      createdAt: pin.createdAt,
    );
  }
}
