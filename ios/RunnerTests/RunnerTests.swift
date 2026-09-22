import XCTest
@testable import Runner

/// iOSのネイティブ実装がPinを永続化できることを検証する。
class RunnerTests: XCTestCase {

  /// Pinの保存・取得・更新・削除と作成日時順の取得を検証する。
  func testPinStorageCrudAndOrdering() throws {
    let directoryURL = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer { try? FileManager.default.removeItem(at: directoryURL) }

    let storage = try PinStorage(databaseURL: directoryURL.appendingPathComponent("test.db"))
    let olderID = try storage.savePin(latitude: 35.0, longitude: 139.0, createdAt: 1000)
    let newerID = try storage.savePin(latitude: 36.0, longitude: 140.0, createdAt: 2000)

    try storage.updateMemo(id: olderID, memo: "old pin")
    try storage.updateReviewStatus(id: olderID, reviewed: true)

    let pins = try storage.fetchPins()
    XCTAssertEqual(pins.count, 2)
    XCTAssertEqual(pins[0]["id"] as? Int64, newerID)
    XCTAssertEqual(pins[1]["id"] as? Int64, olderID)
    XCTAssertEqual(pins[1]["memo"] as? String, "old pin")
    XCTAssertEqual(pins[1]["reviewed"] as? Int32, 1)

    try storage.deletePin(id: newerID)
    XCTAssertEqual(try storage.fetchPins().count, 1)
  }
}
