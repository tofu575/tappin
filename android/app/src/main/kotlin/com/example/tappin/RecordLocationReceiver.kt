package com.example.tappin

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.location.Geocoder
import android.location.Location
import android.location.LocationManager
import java.util.Calendar
import java.util.Locale

class RecordLocationReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val pendingResult = goAsync()

        Thread {
            val prefs = context.getSharedPreferences("HomeWidgetPlugin", Context.MODE_PRIVATE)

            prefs.edit().putString("state", "loading").apply()
            refreshWidget(context)

            try {
                val location = getBestLastLocation(context)
                    ?: error("位置情報を取得できませんでした。GPSをONにしてください。")

                saveToDatabase(context, location)

                val address = resolveAddress(context, location)
                val timestamp = formatTimestamp(System.currentTimeMillis())

                prefs.edit()
                    .putString("state", "idle")
                    .putString("address", address)
                    .putString("timestamp", timestamp)
                    .apply()
                refreshWidget(context)

            } catch (e: SecurityException) {
                prefs.edit()
                    .putString("state", "error")
                    .putString("address", "位置情報の許可が必要です")
                    .apply()
                refreshWidget(context)
            } catch (e: Exception) {
                prefs.edit()
                    .putString("state", "error")
                    .putString("address", e.message ?: "エラーが発生しました")
                    .apply()
                refreshWidget(context)
            } finally {
                pendingResult.finish()
            }
        }.start()
    }

    @Throws(SecurityException::class)
    private fun getBestLastLocation(context: Context): Location? {
        val lm = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        return listOf(LocationManager.GPS_PROVIDER, LocationManager.NETWORK_PROVIDER)
            .mapNotNull { provider ->
                try { lm.getLastKnownLocation(provider) } catch (_: Exception) { null }
            }
            .maxByOrNull { it.time }
    }

    private fun saveToDatabase(context: Context, location: Location) {
        val dbFile = context.getDatabasePath("tappin.db")
        check(dbFile.exists()) { "アプリを一度起動してからお試しください" }

        SQLiteDatabase.openDatabase(
            dbFile.absolutePath, null, SQLiteDatabase.OPEN_READWRITE
        ).use { db ->
            db.insert("pins", null, ContentValues().apply {
                put("latitude", location.latitude)
                put("longitude", location.longitude)
                put("created_at", System.currentTimeMillis())
            })
        }
    }

    @Suppress("DEPRECATION")
    private fun resolveAddress(context: Context, location: Location): String {
        val fallback = "%.6f, %.6f".format(location.latitude, location.longitude)
        return try {
            val addresses = Geocoder(context, Locale.JAPANESE)
                .getFromLocation(location.latitude, location.longitude, 1)
            if (addresses.isNullOrEmpty()) return fallback
            val addr = addresses[0]
            listOfNotNull(addr.adminArea, addr.subAdminArea, addr.thoroughfare)
                .joinToString("")
                .ifEmpty { fallback }
        } catch (_: Exception) {
            fallback
        }
    }

    private fun formatTimestamp(millis: Long): String {
        val c = Calendar.getInstance().apply { timeInMillis = millis }
        return "%04d/%02d/%02d %02d:%02d".format(
            c.get(Calendar.YEAR),
            c.get(Calendar.MONTH) + 1,
            c.get(Calendar.DAY_OF_MONTH),
            c.get(Calendar.HOUR_OF_DAY),
            c.get(Calendar.MINUTE)
        )
    }

    private fun refreshWidget(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(
            ComponentName(context, TappinWidgetProvider::class.java)
        )
        TappinWidgetProvider().onUpdate(context, manager, ids)
    }
}
