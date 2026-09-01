import Foundation
import SQLite3

private let sqliteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

/// PinをiOSのSQLiteデータベースへ永続化する。
final class PinStorage {
  private let databaseURL: URL

  /// 指定されたSQLiteファイルを保存先として初期化する。
  init(databaseURL: URL) throws {
    self.databaseURL = databaseURL
    try FileManager.default.createDirectory(
      at: databaseURL.deletingLastPathComponent(),
      withIntermediateDirectories: true
    )
    try withDatabase { database in
      try execute(
        database,
        sql: """
          CREATE TABLE IF NOT EXISTS pins (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            created_at INTEGER NOT NULL,
            memo TEXT NOT NULL,
            reviewed INTEGER NOT NULL DEFAULT 0
          )
          """
      )
    }
  }

  /// Application Support配下を保存先とする本番用Storageを生成する。
  static func makeDefault() throws -> PinStorage {
    let applicationSupportURL = FileManager.default.urls(
      for: .applicationSupportDirectory,
      in: .userDomainMask
    )[0]
    return try PinStorage(
      databaseURL: applicationSupportURL
        .appendingPathComponent("tappin", isDirectory: true)
        .appendingPathComponent("tappin.db", isDirectory: false)
    )
  }

  /// 保存済みPinを作成日時の新しい順で返す。
  func fetchPins() throws -> [[String: Any]] {
    try withDatabase { database in
      let statement = try prepare(
        database,
        sql: """
          SELECT id, latitude, longitude, created_at, memo, reviewed
          FROM pins
          ORDER BY created_at DESC
          """
      )
      defer { sqlite3_finalize(statement) }

      var pins: [[String: Any]] = []
      while sqlite3_step(statement) == SQLITE_ROW {
        pins.append([
          "id": sqlite3_column_int64(statement, 0),
          "latitude": sqlite3_column_double(statement, 1),
          "longitude": sqlite3_column_double(statement, 2),
          "created_at": sqlite3_column_int64(statement, 3),
          "memo": String(cString: sqlite3_column_text(statement, 4)),
          "reviewed": sqlite3_column_int(statement, 5),
        ])
      }
      try ensureCompleted(statement, database: database)
      return pins
    }
  }

  /// 新しいPinを保存して自動採番されたIDを返す。
  func savePin(latitude: Double, longitude: Double, createdAt: Int64) throws -> Int64 {
    try withDatabase { database in
      let statement = try prepare(
        database,
        sql: """
          INSERT INTO pins (latitude, longitude, created_at, memo, reviewed)
          VALUES (?, ?, ?, '', 0)
          """
      )
      defer { sqlite3_finalize(statement) }

      sqlite3_bind_double(statement, 1, latitude)
      sqlite3_bind_double(statement, 2, longitude)
      sqlite3_bind_int64(statement, 3, createdAt)
      try step(statement, database: database)
      return sqlite3_last_insert_rowid(database)
    }
  }

  /// 指定されたPinのメモを更新する。
  func updateMemo(id: Int64, memo: String) throws {
    try withDatabase { database in
      let statement = try prepare(database, sql: "UPDATE pins SET memo = ? WHERE id = ?")
      defer { sqlite3_finalize(statement) }

      sqlite3_bind_text(statement, 1, memo, -1, sqliteTransient)
      sqlite3_bind_int64(statement, 2, id)
      try step(statement, database: database)
    }
  }

  /// 指定されたPinの確認状態を更新する。
  func updateReviewStatus(id: Int64, reviewed: Bool) throws {
    try withDatabase { database in
      let statement = try prepare(
        database,
        sql: "UPDATE pins SET reviewed = ? WHERE id = ?"
      )
      defer { sqlite3_finalize(statement) }

      sqlite3_bind_int(statement, 1, reviewed ? 1 : 0)
      sqlite3_bind_int64(statement, 2, id)
      try step(statement, database: database)
    }
  }

  /// 指定されたPinを削除する。
  func deletePin(id: Int64) throws {
    try withDatabase { database in
      let statement = try prepare(database, sql: "DELETE FROM pins WHERE id = ?")
      defer { sqlite3_finalize(statement) }

      sqlite3_bind_int64(statement, 1, id)
      try step(statement, database: database)
    }
  }

  /// SQLite接続を開き、処理完了後に必ず閉じる。
  private func withDatabase<T>(_ operation: (OpaquePointer) throws -> T) throws -> T {
    var database: OpaquePointer?
    guard sqlite3_open(databaseURL.path, &database) == SQLITE_OK, let database else {
      let message = database.map { String(cString: sqlite3_errmsg($0)) } ?? "open failed"
      sqlite3_close(database)
      throw PinStorageError.database(message)
    }
    defer { sqlite3_close(database) }
    return try operation(database)
  }

  /// 値を返さないSQLを実行する。
  private func execute(_ database: OpaquePointer, sql: String) throws {
    if sqlite3_exec(database, sql, nil, nil, nil) != SQLITE_OK {
      throw PinStorageError.database(String(cString: sqlite3_errmsg(database)))
    }
  }

  /// SQLをコンパイルしてStatementを返す。
  private func prepare(_ database: OpaquePointer, sql: String) throws -> OpaquePointer {
    var statement: OpaquePointer?
    guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK,
          let statement else {
      throw PinStorageError.database(String(cString: sqlite3_errmsg(database)))
    }
    return statement
  }

  /// 更新Statementを最後まで実行する。
  private func step(_ statement: OpaquePointer, database: OpaquePointer) throws {
    guard sqlite3_step(statement) == SQLITE_DONE else {
      throw PinStorageError.database(String(cString: sqlite3_errmsg(database)))
    }
  }

  /// SELECT Statementが正常終了したことを検証する。
  private func ensureCompleted(_ statement: OpaquePointer, database: OpaquePointer) throws {
    guard sqlite3_errcode(database) == SQLITE_OK || sqlite3_errcode(database) == SQLITE_DONE else {
      throw PinStorageError.database(String(cString: sqlite3_errmsg(database)))
    }
  }
}

/// iOSのPin永続化で発生したエラーを表す。
private enum PinStorageError: LocalizedError {
  case database(String)

  var errorDescription: String? {
    switch self {
    case let .database(message):
      return message
    }
  }
}
