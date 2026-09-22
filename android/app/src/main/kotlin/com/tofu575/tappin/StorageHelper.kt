package com.tofu575.tappin

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

private const val DB_NAME = "tappin.db"
private const val DB_VERSION = 2
private const val TABLE_NAME = "pins"

class TappinDbHelper(context: Context) : SQLiteOpenHelper(context, DB_NAME, null, DB_VERSION) {

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL("""
            CREATE TABLE IF NOT EXISTS $TABLE_NAME (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                latitude REAL NOT NULL,
                longitude REAL NOT NULL,
                created_at INTEGER NOT NULL,
                memo TEXT NOT NULL,
                reviewed INTEGER NOT NULL DEFAULT 0
            )
        """.trimIndent())
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        if (oldVersion < 2) {
            db.execSQL("ALTER TABLE $TABLE_NAME ADD COLUMN reviewed INTEGER NOT NULL DEFAULT 0")
        }
    }
}

object StorageHelper {

    fun fetchPins(context: Context): List<Map<String, Any?>> {
        val helper = TappinDbHelper(context)
        return helper.readableDatabase.use { db ->
            val cursor = db.query(TABLE_NAME, null, null, null, null, null, "created_at DESC")
            cursor.use {
                val pins = mutableListOf<Map<String, Any?>>()
                while (cursor.moveToNext()) {
                    val memoIndex = cursor.getColumnIndexOrThrow("memo")
                    val memo = if (cursor.isNull(memoIndex)) null else cursor.getString(memoIndex)
                    pins.add(
                        mapOf(
                            "id" to cursor.getLong(cursor.getColumnIndexOrThrow("id")),
                            "latitude" to cursor.getDouble(cursor.getColumnIndexOrThrow("latitude")),
                            "longitude" to cursor.getDouble(cursor.getColumnIndexOrThrow("longitude")),
                            "created_at" to cursor.getLong(cursor.getColumnIndexOrThrow("created_at")),
                            "memo" to memo,
                            "reviewed" to cursor.getInt(cursor.getColumnIndexOrThrow("reviewed")),
                        )
                    )
                }
                pins
            }
        }
    }

    fun updateMemo(context: Context, id: Long, memo: String) {
        val helper = TappinDbHelper(context)
        helper.writableDatabase.use { db ->
            db.update(TABLE_NAME, ContentValues().apply {
                put("memo", memo)
            }, "id = ?", arrayOf(id.toString()))
        }
    }

    fun updateReviewStatus(context: Context, id: Long, reviewed: Boolean) {
        val helper = TappinDbHelper(context)
        helper.writableDatabase.use { db ->
            db.update(TABLE_NAME, ContentValues().apply {
                put("reviewed", if (reviewed) 1 else 0)
            }, "id = ?", arrayOf(id.toString()))
        }
    }

    fun savePin(context: Context, latitude: Double, longitude: Double, createdAt: Long): Long {
        val helper = TappinDbHelper(context)
        return helper.writableDatabase.use { db ->
            db.insert(TABLE_NAME, null, ContentValues().apply {
                put("latitude", latitude)
                put("longitude", longitude)
                put("created_at", createdAt)
                put("memo", "")
                put("reviewed", 0)
            })
        }
    }

    fun deletePin(context: Context, id: Long) {
        val helper = TappinDbHelper(context)
        helper.writableDatabase.use { db ->
            db.delete(TABLE_NAME, "id = ?", arrayOf(id.toString()))
        }
    }
}
