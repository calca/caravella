package io.caravella.egm

import android.content.Context
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.CancellationSignal
import android.os.Handler
import android.os.Looper
import androidx.core.location.LocationManagerCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Device position from the platform [LocationManager] — no Google Play
 * Services. Backs `LocationManagerPositionProvider` on the Dart side, which
 * the app uses when the build has no Google integrations (F-Droid); Play
 * builds use Google's fused provider through `geolocator` instead.
 *
 * Methods:
 * - `isLocationEnabled` → Boolean
 * - `getCurrentPosition` {`fine`: Boolean, `timeoutMs`: Int} → Map or null
 *
 * Runtime permissions are requested on the Dart side (permission_handler);
 * without them `getCurrentPosition` returns null.
 */
class LocationChannel(private val context: Context, messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, NAME)
    private val mainHandler = Handler(Looper.getMainLooper())

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isLocationEnabled" -> result.success(
                    LocationManagerCompat.isLocationEnabled(locationManager())
                )
                "getCurrentPosition" -> getCurrentPosition(
                    fine = call.argument<Boolean>("fine") ?: true,
                    timeoutMs = (call.argument<Int>("timeoutMs") ?: 10_000).toLong(),
                    reply = { result.success(it) },
                )
                else -> result.notImplemented()
            }
        }
    }

    fun dispose() = channel.setMethodCallHandler(null)

    private fun locationManager() =
        context.getSystemService(Context.LOCATION_SERVICE) as LocationManager

    /** Picks the best enabled provider: the platform (AOSP) fused one, GPS or network. */
    private fun provider(lm: LocationManager, fine: Boolean): String? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
            lm.hasProvider(LocationManager.FUSED_PROVIDER) &&
            lm.isProviderEnabled(LocationManager.FUSED_PROVIDER)
        ) return LocationManager.FUSED_PROVIDER
        val order = if (fine) {
            listOf(LocationManager.GPS_PROVIDER, LocationManager.NETWORK_PROVIDER)
        } else {
            listOf(LocationManager.NETWORK_PROVIDER, LocationManager.GPS_PROVIDER)
        }
        return order.firstOrNull { runCatching { lm.isProviderEnabled(it) }.getOrDefault(false) }
    }

    private fun lastKnown(lm: LocationManager): Location? =
        lm.allProviders
            .mapNotNull { runCatching { lm.getLastKnownLocation(it) }.getOrNull() }
            .maxByOrNull { it.time }

    @Suppress("DEPRECATION") // requestSingleUpdate is the pre-API-30 one-shot API.
    private fun getCurrentPosition(fine: Boolean, timeoutMs: Long, reply: (Map<String, Any?>?) -> Unit) {
        val lm = locationManager()
        val provider = provider(lm, fine)
        if (provider == null) {
            reply(null)
            return
        }

        var done = false
        val cancel = CancellationSignal()
        var listener: LocationListener? = null
        fun finish(location: Location?) {
            if (done) return
            done = true
            cancel.cancel()
            listener?.let { runCatching { lm.removeUpdates(it) } }
            reply((location ?: lastKnown(lm))?.toMap())
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                lm.getCurrentLocation(provider, cancel, context.mainExecutor) { finish(it) }
            } else {
                listener = LocationListener { finish(it) }
                lm.requestSingleUpdate(provider, listener, Looper.getMainLooper())
            }
        } catch (e: SecurityException) {
            finish(null)
            return
        } catch (e: IllegalArgumentException) {
            finish(null)
            return
        }
        mainHandler.postDelayed({ finish(null) }, timeoutMs)
    }

    private fun Location.toMap(): Map<String, Any?> = mapOf(
        "latitude" to latitude,
        "longitude" to longitude,
        "altitude" to if (hasAltitude()) altitude else null,
        "accuracy" to if (hasAccuracy()) accuracy.toDouble() else null,
        "timestamp" to time,
    )

    companion object {
        const val NAME = "io.caravella.egm/location"
    }
}
