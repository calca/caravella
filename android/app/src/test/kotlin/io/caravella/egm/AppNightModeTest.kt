package io.caravella.egm

import android.app.UiModeManager
import org.junit.Assert.assertEquals
import org.junit.Test

/** The app's theme preference mapped to Android's night modes. */
class AppNightModeTest {

    @Test
    fun `light and dark force the mode, anything else follows the system`() {
        assertEquals(UiModeManager.MODE_NIGHT_NO, AppNightMode.modeFor("light"))
        assertEquals(UiModeManager.MODE_NIGHT_YES, AppNightMode.modeFor("dark"))
        assertEquals(UiModeManager.MODE_NIGHT_AUTO, AppNightMode.modeFor("system"))
        assertEquals(UiModeManager.MODE_NIGHT_AUTO, AppNightMode.modeFor(null))
    }
}
