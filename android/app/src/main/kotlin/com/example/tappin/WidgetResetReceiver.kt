package com.example.tappin

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import es.antonborri.home_widget.HomeWidgetPlugin

class WidgetResetReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        HomeWidgetPlugin.getData(context).edit()
            .putString("state", "idle")
            .apply()

        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(
            ComponentName(context, TappinWidgetProvider::class.java)
        )
        TappinWidgetProvider().onUpdate(context, manager, ids)
    }
}
