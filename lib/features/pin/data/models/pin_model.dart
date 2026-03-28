import '../../domain/entities/pin.dart';

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
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.millisecondsSinceEpoch,
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
