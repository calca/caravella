package io.caravella.egm

import android.animation.ValueAnimator
import android.app.Activity
import android.os.SystemClock
import android.view.animation.AccelerateInterpolator
import android.view.animation.DecelerateInterpolator
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.core.splashscreen.SplashScreenViewProvider

/**
 * The launch splash (LaunchTheme in res/values/styles.xml): Home's page color
 * with the app icon.
 *
 * It stays until Flutter says Home is drawn with its groups (`homeReady` on
 * [CHANNEL], sent by lib/main/startup_splash.dart), so Home never shows empty,
 * and at most [MAX_WAIT_MS] from the start. Then the icon shrinks and fades
 * while the page color fades into Home, and Home's cards rise in Flutter.
 * With animations turned off on the phone it just goes.
 */
class StartupSplash private constructor() {
    private val startedAt = SystemClock.uptimeMillis()

    /** Set when Flutter's Home is ready (main thread). */
    var homeReady = false

    private fun keepOnScreen() =
        !homeReady && SystemClock.uptimeMillis() - startedAt < MAX_WAIT_MS

    companion object {
        const val CHANNEL = "io.caravella.egm/splash"

        /** A safety limit: past it the splash goes even if Home isn't ready. */
        private const val MAX_WAIT_MS = 1500L

        /** Call in onCreate, before super.onCreate. */
        fun install(activity: Activity): StartupSplash {
            val state = StartupSplash()
            val splash = activity.installSplashScreen()
            splash.setKeepOnScreenCondition { state.keepOnScreen() }
            splash.setOnExitAnimationListener(::animateOut)
            return state
        }

        private fun animateOut(provider: SplashScreenViewProvider) {
            if (!ValueAnimator.areAnimatorsEnabled()) {
                provider.remove()
                return
            }
            provider.iconView.animate()
                .scaleX(0.55f)
                .scaleY(0.55f)
                .alpha(0f)
                .setDuration(220)
                .setInterpolator(AccelerateInterpolator())
                .start()
            provider.view.animate()
                .alpha(0f)
                .setStartDelay(80)
                .setDuration(300)
                .setInterpolator(DecelerateInterpolator())
                .withEndAction { provider.remove() }
                .start()
        }
    }
}
