import Flutter
import Foundation

private let channelName = "com.tofu575.tappin/native"
private let invalidArgumentsError = "INVALID_ARGUMENTS"
private let storageError = "STORAGE_ERROR"

/// Flutterから呼ばれるiOSネイティブ処理をMethodChannelへ接続する。
final class NativeBridge {
  private let storage: PinStorage
  private var channel: FlutterMethodChannel?

  /// 必須のPin保存先を受け取ってBridgeを初期化する。
  init(storage: PinStorage) {
    self.storage = storage
  }

  /// アプリ用MethodChannelへネイティブ処理を登録する。
  func register(binaryMessenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: binaryMessenger)
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
    self.channel = channel
  }

  /// MethodChannelの呼び出しを対応するStorage処理へ振り分ける。
  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    do {
      switch call.method {
      case "storage/getPins":
        result(try storage.fetchPins())
      case "storage/savePin":
        try handleSavePin(call, result: result)
      case "storage/deletePin":
        try handleDeletePin(call, result: result)
      case "storage/updateMemo":
        try handleUpdateMemo(call, result: result)
      case "storage/updateReviewStatus":
        try handleUpdateReviewStatus(call, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    } catch let error as NativeBridgeError {
      result(FlutterError(code: invalidArgumentsError, message: error.localizedDescription, details: nil))
    } catch {
      result(FlutterError(code: storageError, message: error.localizedDescription, details: nil))
    }
  }

  /// MethodChannelの引数からPinを組み立てて保存する。
  private func handleSavePin(_ call: FlutterMethodCall, result: FlutterResult) throws {
    let arguments = try arguments(from: call)
    guard let latitude = arguments["latitude"] as? NSNumber,
          let longitude = arguments["longitude"] as? NSNumber,
          let createdAt = arguments["createdAt"] as? NSNumber else {
      throw NativeBridgeError.invalidArguments("latitude, longitude, createdAt が必要です")
    }
    let id = try storage.savePin(
      latitude: latitude.doubleValue,
      longitude: longitude.doubleValue,
      createdAt: createdAt.int64Value
    )
    result(id)
  }

  /// MethodChannelで指定されたPinを削除する。
  private func handleDeletePin(_ call: FlutterMethodCall, result: FlutterResult) throws {
    let arguments = try arguments(from: call)
    guard let id = arguments["id"] as? NSNumber else {
      throw NativeBridgeError.invalidArguments("id が必要です")
    }
    try storage.deletePin(id: id.int64Value)
    result(nil)
  }

  /// MethodChannelで指定されたPinのメモを更新する。
  private func handleUpdateMemo(_ call: FlutterMethodCall, result: FlutterResult) throws {
    let arguments = try arguments(from: call)
    guard let id = arguments["id"] as? NSNumber,
          let memo = arguments["memo"] as? String else {
      throw NativeBridgeError.invalidArguments("id と memo が必要です")
    }
    try storage.updateMemo(id: id.int64Value, memo: memo)
    result(nil)
  }

  /// MethodChannelで指定されたPinの確認状態を更新する。
  private func handleUpdateReviewStatus(
    _ call: FlutterMethodCall,
    result: FlutterResult
  ) throws {
    let arguments = try arguments(from: call)
    guard let id = arguments["id"] as? NSNumber,
          let reviewed = arguments["reviewed"] as? Bool else {
      throw NativeBridgeError.invalidArguments("id と reviewed が必要です")
    }
    try storage.updateReviewStatus(id: id.int64Value, reviewed: reviewed)
    result(nil)
  }

  /// MethodCallの引数をDictionaryとして検証する。
  private func arguments(from call: FlutterMethodCall) throws -> [String: Any] {
    guard let arguments = call.arguments as? [String: Any] else {
      throw NativeBridgeError.invalidArguments("引数が必要です")
    }
    return arguments
  }
}

/// MethodChannelへ渡された不正な引数を表す。
private enum NativeBridgeError: LocalizedError {
  case invalidArguments(String)

  var errorDescription: String? {
    switch self {
    case let .invalidArguments(message):
      return message
    }
  }
}
