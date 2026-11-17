package io.caravella.egm

import android.app.UiModeManager
import android.content.Context
import android.os.Build

/**
 * Tells Android the app's own theme choice (Settings › Appearance), so the
 * system draws Caravella in it too: the launch splash, the window's
 * background before Flutter's first frame, coming back from the launcher.
 * Without it a phone in dark mode showed the dark window first and then the
 * app's light Home, and the other way round.
 *
 * Android 12+ ([UiModeManager.setApplicationNightMode], which the system
 * remembers across starts); nothing on older versions. The activity
 * declares `uiMode` in its configChanges, so a change isn't a restart.
 * Called from lib/main/app_night_mode.dart over [CHANNEL].
 */
object AppNightMode {
    const val CHANNEL = "io.caravella.egm/night_mode"

    /** The app's `theme_mode` preference ("light", "dark", "system") as a UiModeManager mode. */
    fun modeFor(themeMode: String?): Int = when (themeMode) {
        "light" -> UiModeManager.MODE_NIGHT_NO
        "dark" -> UiModeManager.MODE_NIGHT_YES
        else -> UiModeManager.MODE_NIGHT_AUTO
    }

    /** Returns whether Android was told (false before Android 12). */
    fun apply(context: Context, themeMode: String?): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return false
        val manager = context.getSystemService(UiModeManager::class.java) ?: return false
        manager.setApplicationNightMode(modeFor(themeMode))
        return true
    }
}
