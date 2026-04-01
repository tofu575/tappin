package com.example.tappin

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.view.View
import android.widget.RemoteViews
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
        val address = prefs.getString("address", "") ?: ""
        val timestamp = prefs.getString("timestamp", "") ?: ""

        val views = RemoteViews(context.packageName, R.layout.home_widget_layout)

        when {
            state == "loading" || state.startsWith("record_") -> {
                views.setInt(R.id.widget_container, "setBackgroundResource", R.drawable.widget_background_loading)
                views.setTextColor(R.id.widget_dot, Color.WHITE)
                views.setTextColor(R.id.widget_header_label, Color.parseColor("#BBDEFB"))
                views.setViewVisibility(R.id.idle_content, View.GONE)
                views.setViewVisibility(R.id.loading_content, View.VISIBLE)
                views.setViewVisibility(R.id.result_content, View.GONE)
            }
            state == "complete" -> {
                views.setInt(R.id.widget_container, "setBackgroundResource", R.drawable.widget_background)
                views.setTextColor(R.id.widget_dot, Color.parseColor("#4CAF50"))
                views.setTextColor(R.id.widget_header_label, Color.parseColor("#9E9E9E"))
                views.setViewVisibility(R.id.idle_content, View.GONE)
                views.setViewVisibility(R.id.loading_content, View.GONE)
                views.setViewVisibility(R.id.result_content, View.VISIBLE)
                views.setTextColor(R.id.widget_address, Color.parseColor("#212121"))
                views.setTextViewText(R.id.widget_address, address)
                views.setTextViewText(R.id.widget_timestamp, timestamp)
                views.setViewVisibility(
                    R.id.widget_timestamp,
                    if (timestamp.isEmpty()) View.GONE else View.VISIBLE
                )
            }
            state == "error" -> {
                views.setInt(R.id.widget_container, "setBackgroundResource", R.drawable.widget_background_error)
                views.setTextColor(R.id.widget_dot, Color.parseColor("#D32F2F"))
                views.setTextColor(R.id.widget_header_label, Color.parseColor("#9E9E9E"))
                views.setViewVisibility(R.id.idle_content, View.GONE)
                views.setViewVisibility(R.id.loading_content, View.GONE)
                views.setViewVisibility(R.id.result_content, View.VISIBLE)
                views.setTextColor(R.id.widget_address, Color.parseColor("#D32F2F"))
                views.setTextViewText(R.id.widget_address, address)
                views.setViewVisibility(R.id.widget_timestamp, View.GONE)
            }
            else -> { // idle
                views.setInt(R.id.widget_container, "setBackgroundResource", R.drawable.widget_background)
                views.setTextColor(R.id.widget_dot, Color.parseColor("#4CAF50"))
                views.setTextColor(R.id.widget_header_label, Color.parseColor("#9E9E9E"))
                views.setViewVisibility(R.id.idle_content, View.VISIBLE)
                views.setViewVisibility(R.id.loading_content, View.GONE)
                views.setViewVisibility(R.id.result_content, View.GONE)
            }
        }

        val recordIntent = PendingIntent.getBroadcast(
            context,
            0,
            Intent(context, RecordLocationReceiver::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_container, recordIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
