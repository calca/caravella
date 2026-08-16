package io.caravella.egm

import java.util.Locale
import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * Plain-JVM unit tests for the pure helpers in WidgetFormatting.kt.
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
}
