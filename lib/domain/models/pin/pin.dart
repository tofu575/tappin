import 'package:tappin/domain/models/location/latitude.dart';
import 'package:tappin/domain/models/location/longitude.dart';
import 'package:tappin/domain/models/core/my_datetime.dart';
import 'package:tappin/domain/models/pin/memo.dart';
import 'package:tappin/domain/models/pin/pin_review_status.dart';

/// 記録した位置・日時と、あとで確認するための補助情報を保持する。
class Pin {
  final int? id;
  final Latitude latitude;
  final Longitude longitude;
  final MyDatetime createdAt;
  final Memo? memo;
  final PinReviewStatus reviewStatus;

  const Pin({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.memo,
    this.reviewStatus = PinReviewStatus.unreviewed,
  });

  factory Pin.fromMap(Map<String, dynamic> map) {
    final memoValue = map['memo'] as String?;
    return Pin(
      id: map['id'] as int?,
      latitude: Latitude(map['latitude'] as double),
      longitude: Longitude(map['longitude'] as double),
      createdAt: MyDatetime(
        DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      ),
      memo: memoValue != null ? Memo(memoValue) : null,
      reviewStatus: (map['reviewed'] as num? ?? 0).toInt() == 1
          ? PinReviewStatus.reviewed
          : PinReviewStatus.unreviewed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'latitude': latitude.value,
      'longitude': longitude.value,
      'created_at': createdAt.value.millisecondsSinceEpoch,
      if (memo != null) 'memo': memo!.value,
      'reviewed': reviewStatus == PinReviewStatus.reviewed ? 1 : 0,
    };
  }
}
