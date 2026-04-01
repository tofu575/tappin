package com.example.tappin

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.location.Geocoder
import android.location.Location
import android.os.SystemClock
import es.antonborri.home_widget.HomeWidgetPlugin
import java.util.Calendar
import java.util.Locale
import java.util.concurrent.atomic.AtomicBoolean

class RecordLocationReceiver : BroadcastReceiver() {

    companion object {
        private const val RESET_DELAY_MS = 3_000L
        private const val ANIM_FRAME_MS = 300L
    }

    override fun onReceive(context: Context, intent: Intent) {
        val pendingResult = goAsync()

        Thread {
            val prefs = context.getSharedPreferences("HomeWidgetPlugin", Context.MODE_PRIVATE)

            prefs.edit().putString("state", "loading").apply()
            refreshWidget(context)

            try {
                val location = LocationHelper.fetchLocation(context)

                saveToDatabase(context, location)

                if (location == null) {
                    setError(context, "位置情報を取得できませんでした")
                } else {
                    StorageHelper.savePin(context, location.latitude, location.longitude, System.currentTimeMillis())
                    val address = resolveAddress(context, location)
                    val timestamp = formatTimestamp(System.currentTimeMillis())
                    setComplete(context, address, timestamp)
                }
                scheduleReset(context)

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

    private fun startAnimationThread(context: Context, done: AtomicBoolean): Thread {
        return Thread {
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
