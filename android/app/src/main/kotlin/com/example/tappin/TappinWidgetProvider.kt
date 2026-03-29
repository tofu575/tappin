package com.example.tappin

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.Color
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetPlugin

class TappinWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val prefs = HomeWidgetPlugin.getData(context)
        val state = prefs.getString("state", "idle") ?: "idle"
        val address = prefs.getString("address", "タップして記録") ?: "タップして記録"
        val timestamp = prefs.getString("timestamp", "") ?: ""

        val views = RemoteViews(context.packageName, R.layout.home_widget_layout)

        when {
            state.startsWith("record_") || state == "loading" -> {
                val dotCount = when (state) {
                    "record_1" -> " ·"
                    "record_2" -> " ··"
                    "record_3" -> " ···"
                    else -> ""
                }
                views.setInt(R.id.widget_container, "setBackgroundResource", R.drawable.widget_background_loading)
                views.setTextColor(R.id.widget_dot, Color.WHITE)
                views.setTextViewText(R.id.widget_dot, "●")
                views.setTextColor(R.id.widget_address, Color.WHITE)
                views.setTextViewText(R.id.widget_address, "記録中$dotCount")
                views.setViewVisibility(R.id.widget_timestamp, View.INVISIBLE)
            }
            state == "error" -> {
                views.setInt(R.id.widget_container, "setBackgroundResource", R.drawable.widget_background_error)
                views.setTextColor(R.id.widget_dot, Color.parseColor("#D32F2F"))
                views.setTextViewText(R.id.widget_dot, "⚠")
                views.setTextColor(R.id.widget_address, Color.parseColor("#D32F2F"))
                views.setTextViewText(R.id.widget_address, address)
                views.setViewVisibility(R.id.widget_timestamp, View.INVISIBLE)
            }
            else -> {
                views.setInt(R.id.widget_container, "setBackgroundResource", R.drawable.widget_background)
                views.setTextColor(R.id.widget_dot, Color.parseColor("#4CAF50"))
                views.setTextViewText(R.id.widget_dot, "●")
                views.setTextColor(R.id.widget_address, Color.parseColor("#212121"))
                views.setTextViewText(R.id.widget_address, address)
                views.setTextViewText(R.id.widget_timestamp, timestamp)
                views.setViewVisibility(
                    R.id.widget_timestamp,
                    if (timestamp.isEmpty()) View.GONE else View.VISIBLE
                )
            }
        }

        val recordIntent = HomeWidgetBackgroundIntent.getBroadcast(
            context,
            Uri.parse("homeWidget://record")
        )
        views.setOnClickPendingIntent(R.id.widget_container, recordIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
