package com.example.tappin

import android.content.Context
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Bundle
import android.os.HandlerThread
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicInteger
import java.util.concurrent.atomic.AtomicReference

object LocationHelper {

    private const val LOCATION_TIMEOUT_SEC = 8L
    private const val MAX_CACHED_LOCATION_AGE_MS = 30_000L
    private const val MAX_CACHED_LOCATION_ACCURACY_METERS = 50F

    @Suppress("DEPRECATION")
    @Throws(SecurityException::class)
    fun fetchLocation(context: Context): Location? {
        val lm = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager

        val providers = listOf(
            LocationManager.GPS_PROVIDER,
            LocationManager.NETWORK_PROVIDER,
        ).filter { lm.isProviderEnabled(it) }
        if (providers.isEmpty()) return null

        val cachedLocation = providers
            .mapNotNull { lm.getLastKnownLocation(it) }
            .filter(::canReuse)
            .minByOrNull { it.accuracy }
        if (cachedLocation != null) {
            return cachedLocation
        }

        val latch = CountDownLatch(1)
        val result = AtomicReference<Location?>(null)
        val remainingProviders = AtomicInteger(providers.size)
        val looperThread = HandlerThread("LocThread").apply { start() }

        val listener = object : LocationListener {
            override fun onLocationChanged(loc: Location) {
                val current = result.get()
                if (current == null || loc.accuracy < current.accuracy) {
                    result.set(loc)
                }
                if (loc.hasAccuracy() && loc.accuracy <= MAX_CACHED_LOCATION_ACCURACY_METERS) {
                    latch.countDown()
                } else if (remainingProviders.updateAndGet { it - 1 } == 0) {
                    latch.countDown()
                }
            }
            override fun onProviderDisabled(provider: String) {
                if (remainingProviders.updateAndGet { it - 1 } == 0) {
                    latch.countDown()
                }
            }
            override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
        }

        try {
            providers.forEach { provider ->
                lm.requestSingleUpdate(provider, listener, looperThread.looper)
            }
            latch.await(LOCATION_TIMEOUT_SEC, TimeUnit.SECONDS)
        } finally {
            lm.removeUpdates(listener)
            looperThread.quit()
        }

        return result.get()
    }

    private fun canReuse(location: Location): Boolean {
        val age = System.currentTimeMillis() - location.time
        return age in 0..MAX_CACHED_LOCATION_AGE_MS &&
            location.hasAccuracy() &&
            location.accuracy <= MAX_CACHED_LOCATION_ACCURACY_METERS
    }
}
