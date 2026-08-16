package io.caravella.egm

import android.content.Context
import android.content.res.Configuration
import android.os.Build
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.unit.ColorProvider

// Design tokens (spacing, radii, text sizes) for the widget's Compose/Glance
// layouts, kept separate from HomeWidgetProvider.kt's rendering logic.

internal val WidgetInnerPadding = 12.dp
internal val WidgetCompactPadding = 6.dp
internal val WidgetSectionSpacing = 10.dp
internal val WidgetMinimalSpacing = 2.dp
internal val WidgetOuterRadius = 24.dp
internal val WidgetBodyTextSize = 15.sp
internal val WidgetLabelTextSize = 12.sp
internal val WidgetCompactValueTextSize = 16.sp

// 1x1 is much narrower/shorter than 2x2 (57x51dp vs 130x117dp), so its group
// name label and value share the cell at smaller sizes than the 2x2 variants.
internal val WidgetMicroLabelTextSize = 9.sp
internal val WidgetMicroValueTextSize = 14.sp
internal val WidgetGroupTotalValueTextSize = 22.sp
internal val WidgetTodayPillRadius = 16.dp
internal val WidgetTodayPillHorizontalPadding = 8.dp
internal val WidgetTodayPillVerticalPadding = 2.dp
internal val WidgetCtaButtonRadius = 18.dp
internal val WidgetCtaButtonPadding = 18.dp
internal val WidgetCtaButtonTextSize = 28.sp

// Smaller CTA chip variant used by the 4x1 layout, whose ~51dp height can't fit
// the full-size CTA button used by the taller layouts.
internal val WidgetCtaButtonSmallRadius = 14.dp
internal val WidgetCtaButtonSmallPadding = 8.dp
internal val WidgetCtaButtonSmallTextSize = 18.sp
internal val WidgetCtaButtonSmallReservedWidth = 46.dp

/**
 * Creates a [ColorProvider] that resolves to [day] in light mode and [night] in dark mode.
 * Replaces the removed `androidx.glance.color.ColorProvider(day, night)` factory.
 */
internal fun ColorProvider(day: Color, night: Color): ColorProvider {
    return DayNightColorProvider(day, night)
}

private data class DayNightColorProvider(val day: Color, val night: Color) : ColorProvider {
    override fun getColor(context: Context): Color {
        val nightMode = context.resources.configuration.uiMode and
            Configuration.UI_MODE_NIGHT_MASK
        return if (nightMode == Configuration.UI_MODE_NIGHT_YES) night else day
    }
}

// Base widget container surface, matching the app's own brand surface tones
// (packages/caravella_core_ui/lib/themes/caravella_themes.dart).
internal val WidgetSurfaceColor = ColorProvider(
    Color(0xFFFFFFFF), // Light mode
    Color(0xFF181A1B), // Dark mode
)

internal val EmphasisTextColor = ColorProvider(
    Color(0xFF1D1A24), // Light mode
    Color(0xFFF4EEFF), // Dark mode
)

internal val SecondaryTextColor = ColorProvider(
    Color(0xFF5F5A68), // Light mode
    Color(0xFFC8C2D2), // Dark mode
)

// Static palette used when Material You dynamic color isn't available (API <31,
// or the system theme can't be resolved for some reason) — the app's own teal
// brand colors (packages/caravella_core_ui/lib/themes/caravella_themes.dart),
// so the widget matches the rest of the app instead of a generic Material purple.
private val FallbackTodayPillSurface = ColorProvider(
    Color(0xFFB2DFDB), // Light mode (primaryContainer)
    Color(0xFF00695C), // Dark mode (primaryContainer)
)

private val FallbackTodayPillTextColor = ColorProvider(
    Color(0xFF000000), // Light mode (onPrimaryContainer)
    Color(0xFFFFFFFF), // Dark mode (onPrimaryContainer)
)

private val FallbackCtaButtonSurface = ColorProvider(
    Color(0xFF009688), // Light mode (primary)
    Color(0xFF80CBC4), // Dark mode (primary)
)

private val FallbackCtaButtonTextColor = ColorProvider(
    Color(0xFFFFFFFF), // Light mode (onPrimary)
    Color(0xFF003D36), // Dark mode (onPrimary)
)

/** The widget's two branded accent surfaces (CTA button, "today" pill), themed together. */
internal data class WidgetAccentColors(
    val ctaSurface: ColorProvider,
    val ctaText: ColorProvider,
    val pillSurface: ColorProvider,
    val pillText: ColorProvider,
)

private val FallbackWidgetAccentColors = WidgetAccentColors(
    ctaSurface = FallbackCtaButtonSurface,
    ctaText = FallbackCtaButtonTextColor,
    pillSurface = FallbackTodayPillSurface,
    pillText = FallbackTodayPillTextColor,
)

/**
 * Resolves the widget's accent colors from the device's Material You wallpaper
 * palette (Android 12+), so the CTA button and "today" pill follow the user's
 * chosen system theme instead of a fixed color — matching the rest of the app,
 * which already supports dynamic color. Falls back to the static teal palette
 * on older Android versions, or if the system palette can't be resolved.
 */
internal fun widgetAccentColors(context: Context): WidgetAccentColors {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return FallbackWidgetAccentColors
    return try {
        val light = dynamicLightColorScheme(context)
        val dark = dynamicDarkColorScheme(context)
        WidgetAccentColors(
            ctaSurface = ColorProvider(day = light.primary, night = dark.primary),
            ctaText = ColorProvider(day = light.onPrimary, night = dark.onPrimary),
            pillSurface = ColorProvider(day = light.primaryContainer, night = dark.primaryContainer),
            pillText = ColorProvider(day = light.onPrimaryContainer, night = dark.onPrimaryContainer),
        )
    } catch (_: Exception) {
        FallbackWidgetAccentColors
    }
}
