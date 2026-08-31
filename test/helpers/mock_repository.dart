import 'package:tappin/domain/models/core/my_datetime.dart';
import 'package:tappin/domain/models/location/latitude.dart';
import 'package:tappin/domain/models/location/longitude.dart';
import 'package:tappin/domain/models/pin/memo.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/models/pin/pin_review_status.dart';
import 'package:tappin/domain/repositories/repository.dart';

Pin buildTestPin({
  int id = 1,
  Memo? memo,
  PinReviewStatus reviewStatus = PinReviewStatus.unreviewed,
}) => Pin(
  id: id,
  latitude: Latitude(35.6812),
  longitude: Longitude(139.7671),
  createdAt: MyDatetime(DateTime(2024, 1, 15, 10, 30)),
  memo: memo,
  reviewStatus: reviewStatus,
);

class MockRipository implements Repository {
  List<Pin> stubbedPins;
  final List<Pin> savedPins = [];
  final List<int> deletedIds = [];
  final Map<int, Memo> updatedMemos = {};
  final Map<int, PinReviewStatus> updatedReviewStatuses = {};

  MockRipository({this.stubbedPins = const []});

  @override
  Future<List<Pin>> getPins() async => List.from(stubbedPins);

  @override
  Future<int> savePin(Pin pin) async {
    savedPins.add(pin);
    return savedPins.length;
  }

  @override
  Future<void> deletePin(int id) async {
    deletedIds.add(id);
    stubbedPins = stubbedPins.where((p) => p.id != id).toList();
  }

  @override
  Future<void> updateMemo(int id, Memo memo) async {
    updatedMemos[id] = memo;
    stubbedPins = stubbedPins
        .map((pin) => pin.id == id ? _copyPin(pin, memo: memo) : pin)
        .toList();
  }

  @override
  Future<void> updateReviewStatus(int id, PinReviewStatus status) async {
    updatedReviewStatuses[id] = status;
    stubbedPins = stubbedPins
        .map((pin) => pin.id == id ? _copyPin(pin, reviewStatus: status) : pin)
        .toList();
  }
}

/// Mock内のPinを指定された補助情報だけ差し替えて複製する。
Pin _copyPin(Pin pin, {Memo? memo, PinReviewStatus? reviewStatus}) => Pin(
  id: pin.id,
  latitude: pin.latitude,
  longitude: pin.longitude,
  createdAt: pin.createdAt,
  memo: memo ?? pin.memo,
  reviewStatus: reviewStatus ?? pin.reviewStatus,
);
