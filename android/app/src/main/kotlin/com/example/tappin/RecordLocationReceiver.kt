package com.example.tappin

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.location.Geocoder
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Bundle
import android.os.HandlerThread
import android.os.SystemClock
import es.antonborri.home_widget.HomeWidgetPlugin
import java.util.Calendar
import java.util.Locale
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicReference

class RecordLocationReceiver : BroadcastReceiver() {

    companion object {
        private const val LOCATION_TIMEOUT_SEC = 8L
        private const val RESET_DELAY_MS = 10_000L
        private const val ANIM_FRAME_MS = 300L
    }

    override fun onReceive(context: Context, intent: Intent) {
        val pendingResult = goAsync()

        Thread {
            val animDone = AtomicBoolean(false)
            val animThread = startAnimationThread(context, animDone)

            try {
                val location = fetchLocation(context)

                animDone.set(true)
                animThread.interrupt()
                animThread.join(500)

                if (location == null) {
                    setError(context, "位置情報を取得できませんでした")
                } else {
                    saveToDatabase(context, location)
                    val address = resolveAddress(context, location)
                    val timestamp = formatTimestamp(System.currentTimeMillis())
                    setComplete(context, address, timestamp)
                }
                scheduleReset(context)

            } catch (e: SecurityException) {
                animDone.set(true)
                animThread.interrupt()
                animThread.join(500)
                setError(context, "位置情報の許可が必要です")
                scheduleReset(context)
            } catch (e: Exception) {
                animDone.set(true)
                animThread.interrupt()
                animThread.join(500)
                setError(context, "エラーが発生しました")
                scheduleReset(context)
            } finally {
                pendingResult.finish()
            }
        }.start()
    }

    private fun startAnimationThread(context: Context, done: AtomicBoolean): Thread {
        return Thread {
            // ProgressBar の indeterminate アニメーションはシステムが制御するため、
            // ここでは state=loading を維持するだけでよい
            while (!done.get()) {
                try {
                    Thread.sleep(ANIM_FRAME_MS)
                } catch (_: InterruptedException) {
                    return@Thread
                }
            }
        }.also { it.start() }
    }

    @Suppress("DEPRECATION")
    @Throws(SecurityException::class)
    private fun fetchLocation(context: Context): Location? {
        val lm = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager

        val provider = when {
            lm.isProviderEnabled(LocationManager.GPS_PROVIDER) -> LocationManager.GPS_PROVIDER
            lm.isProviderEnabled(LocationManager.NETWORK_PROVIDER) -> LocationManager.NETWORK_PROVIDER
            else -> return null
        }

        val latch = CountDownLatch(1)
        val result = AtomicReference<Location?>(null)
        val looperThread = HandlerThread("LocThread").apply { start() }

        val listener = object : LocationListener {
            override fun onLocationChanged(loc: Location) {
                result.set(loc)
                latch.countDown()
            }
            override fun onProviderDisabled(provider: String) { latch.countDown() }
            override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
        }

        try {
            lm.requestSingleUpdate(provider, listener, looperThread.looper)
            latch.await(LOCATION_TIMEOUT_SEC, TimeUnit.SECONDS)
        } finally {
            lm.removeUpdates(listener)
            looperThread.quit()
        }

        return result.get()
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

    private fun setComplete(context: Context, address: String, timestamp: String) {
        HomeWidgetPlugin.getData(context).edit()
            .putString("state", "complete")
            .putString("address", address)
            .putString("timestamp", timestamp)
            .apply()
        refreshWidget(context)
    }

    private fun setError(context: Context, message: String) {
        HomeWidgetPlugin.getData(context).edit()
            .putString("state", "error")
            .putString("address", message)
            .apply()
        refreshWidget(context)
    }

    private fun scheduleReset(context: Context) {
        val intent = Intent(context, WidgetResetReceiver::class.java)
        val pi = PendingIntent.getBroadcast(
            context, 1, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        am.set(AlarmManager.ELAPSED_REALTIME, SystemClock.elapsedRealtime() + RESET_DELAY_MS, pi)
    }

    private fun refreshWidget(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(
            ComponentName(context, TappinWidgetProvider::class.java)
        )
        TappinWidgetProvider().onUpdate(context, manager, ids)
    }
}
