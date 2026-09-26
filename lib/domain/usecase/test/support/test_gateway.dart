import 'package:model/model.dart';
import 'package:usecase/usecase.dart';

/// Interactorの必須外部境界をメモリ上で実装するテスト用Gateway。
final class TestGateway
    implements
        Repository,
        LocationService,
        GeocodingService,
        ClockGateway,
        HapticGateway,
        ExternalMapGateway,
        OnboardingGateway {
  TestGateway({this.saveError});

  final Object? saveError;
  final coordinate = const Coordinate(
    latitude: Latitude(35.6812),
    longitude: Longitude(139.7671),
  );
  final List<Pin> savedPins = [];
  var currentTime = DateTime(2026);
  var recordSuccessCount = 0;
  var completed = false;

  @override
  Future<void> complete() async => completed = true;

  @override
  Future<void> deletePin(int id) async {}

  @override
  Future<String> fetchAddress(Coordinate coordinate) async => '';

  @override
  Future<Coordinate> fetchCurrentLocation() async => coordinate;

  @override
  Future<List<Pin>> getPins() async => List.unmodifiable(savedPins);

  @override
  bool hasCompleted() => completed;

  @override
  MyDatetime now() => MyDatetime(currentTime);

  @override
  Future<void> open({
    required Coordinate coordinate,
    required ExternalMapDestination destination,
  }) async {}

  @override
  Future<void> openSettings() async {}

  @override
  void playRecordFailure() {}

  @override
  void playRecordSuccess() => recordSuccessCount++;

  @override
  Future<int> savePin(Pin pin) async {
    if (saveError case final error?) {
      throw error;
    }
    savedPins.add(pin);
    return savedPins.length;
  }

  @override
  Future<void> updateMemo(int id, Memo memo) async {}

  @override
  Future<void> updateReviewStatus(int id, PinReviewStatus status) async {}

  @override
  Future<void> warmUp() async {}
}
