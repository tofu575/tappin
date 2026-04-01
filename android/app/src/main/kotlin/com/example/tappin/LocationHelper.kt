package com.example.tappin

import android.content.Context
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Bundle
import android.os.HandlerThread
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicReference

object LocationHelper {

    private const val LOCATION_TIMEOUT_SEC = 8L

    @Suppress("DEPRECATION")
    @Throws(SecurityException::class)
    fun fetchLocation(context: Context): Location? {
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
}
