package io.caravella.egm

import android.graphics.BitmapFactory
import androidx.compose.ui.graphics.toArgb
import java.util.Locale
import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * Plain-JVM unit tests for the pure helpers in WidgetFormatting.kt — no
 * Android framework/Robolectric needed since none of these touch a real
 * Context, resources, or platform APIs beyond simple data-holder classes
 * ([BitmapFactory.Options]' plain public fields).
 */
class WidgetFormattingTest {

    @Test
    fun `formatWidgetAmount pads to two decimals under a fixed locale`() {
        val original = Locale.getDefault()
        try {
            Locale.setDefault(Locale.US)
            assertEquals("12.50 €", formatWidgetAmount(12.5, "€"))
            assertEquals("0.00 €", formatWidgetAmount(0.0, "€"))
            assertEquals("1234.56 USD", formatWidgetAmount(1234.5649, "USD"))
        } finally {
            Locale.setDefault(original)
        }
    }

    @Test
    fun `widgetColor round-trips the packed ARGB int`() {
        val packed = 0xFF6750A4.toInt()
        assertEquals(packed, widgetColor(packed).toArgb())
    }

    @Test
    fun `calculateBitmapSampleSize returns 1 when image already fits`() {
        val options = BitmapFactory.Options().apply {
            outWidth = 100
            outHeight = 80
        }
        assertEquals(1, calculateBitmapSampleSize(options, 200, 200))
    }

    @Test
    fun `calculateBitmapSampleSize halves until both dimensions fit`() {
        val options = BitmapFactory.Options().apply {
            outWidth = 1600
            outHeight = 1200
        }
        // half=(800,600); /1 and /2 both still >= 200 on both axes, /4 drops
        // height to 150 < 200, so sampleSize=4 is the last step before that.
        assertEquals(4, calculateBitmapSampleSize(options, 200, 200))
    }

    @Test
    fun `calculateBitmapSampleSize handles a zero-size image without looping forever`() {
        val options = BitmapFactory.Options().apply {
            outWidth = 0
            outHeight = 0
        }
        assertEquals(1, calculateBitmapSampleSize(options, 200, 200))
    }
}
