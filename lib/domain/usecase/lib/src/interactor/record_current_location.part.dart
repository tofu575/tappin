part of 'interactor.dart';

const _minimumRecordInterval = Duration(milliseconds: 500);

/// 多重実行を抑止し、現在地のPin保存後に成功ハプティクスを開始する。
Future<Pin?> _recordCurrentLocation(Interactor interactor) async {
  if (interactor._isRecording) return null;

  final now = interactor._clockGateway.now();
  final lastRecordTime = interactor._lastRecordTime;
  if (lastRecordTime != null &&
      now.value.difference(lastRecordTime) < _minimumRecordInterval) {
    return null;
  }

  interactor._isRecording = true;
  try {
    final coordinate = await interactor._locationGateway.fetchCurrentLocation();
    final pin = Pin(
      latitude: coordinate.latitude,
      longitude: coordinate.longitude,
      createdAt: now,
    );
    await interactor._repository.savePin(pin);
    interactor._lastRecordTime = now.value;
    interactor._hapticGateway.playRecordSuccess();
    return pin;
  } finally {
    interactor._isRecording = false;
  }
}
