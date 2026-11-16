package io.caravella.egm

import android.content.Context
import android.os.Build
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.unit.ColorProvider
import androidx.glance.color.ColorProvider as GlanceDayNightColorProvider

// Design tokens (spacing, radii, text sizes) for the widget's Compose/Glance
// layouts, kept separate from HomeWidgetProvider.kt's rendering logic.

// 1x1's own inset — kept separate from the 2x2 cell's so enlarging one doesn't
// eat into the much smaller 1x1 cell's already-tight content area.
internal val WidgetCompactPadding = 6.dp
internal val WidgetOuterRadius = 24.dp

// 2x2's uniform inset (same value on every edge, including around the CTA
// button) and inter-line spacing.
internal val WidgetCellPadding = 12.dp
internal val WidgetMinimalSpacing = 4.dp
internal val WidgetLabelTextSize = 18.sp
internal val WidgetCompactValueTextSize = 24.sp

// 1x1 is much narrower/shorter than 2x2 (57x51dp vs 130x117dp), so its group
// name label and value share the cell at smaller sizes than the 2x2 variants.
internal val WidgetMicroLabelTextSize = 10.sp
internal val WidgetMicroValueTextSize = 15.sp

// The 2x2 layout's "week" line, styled as a small colored chip instead of
// plain secondary text — a bit of branded color without adding clutter.
internal val WidgetWeekPillRadius = 10.dp
internal val WidgetWeekPillHorizontalPadding = 7.dp
internal val WidgetWeekPillTextSize = 12.sp

// Deliberately asymmetric — not a mistake. RemoteViews' TextView (Glance's Text
// has no way to turn off `includeFontPadding`) reserves visibly more invisible
// leading above the glyphs than below them, so even with the Box's own
// `contentAlignment = Alignment.Center`, equal top/bottom padding still measured
// the visible glyphs sitting ~2x closer to the pill's bottom edge than its top
// (measured directly off a rendered screenshot: ~10dp top vs ~5dp bottom with
// 2dp/2dp padding). These values compensate for that so the glyphs land centered.
internal val WidgetWeekPillTopPadding = 1.dp
internal val WidgetWeekPillBottomPadding = 6.dp

// The 2x2 layout's only CTA — a fixed-size square (not padding-around-text,
// which renders non-square since a single "+" glyph is taller than it is wide)
// pinned bottom-end of the cell. Sized close to Android's 48dp recommended
// minimum touch target, since the 130x117dp cell has the room for it.
internal val WidgetCtaButtonSize = 44.dp
internal val WidgetCtaButtonRadius = 16.dp
internal val WidgetCtaButtonTextSize = 22.sp

/**
 * Creates a [ColorProvider] that resolves to [day] in light mode and [night] in dark mode.
 *
 * Delegates to Glance's own `androidx.glance.color.ColorProvider(day, night)` rather than a
 * hand-rolled [ColorProvider] implementation: Glance's RemoteViews translator
 * (`ApplyModifiersKt`) only recognizes its own internal color-provider types when resolving
 * `background()`/text-color modifiers — anything else silently falls through with an
 * "Unexpected background/text color modifier" log line and the modifier is dropped entirely.
 * A previous hand-rolled `DayNightColorProvider` class here (same name, different type than
 * Glance's own) hit exactly that fallback, which is why the widget's background and every
 * themed text color rendered as if unset on every device, regardless of host/launcher.
 */
internal fun ColorProvider(day: Color, night: Color): ColorProvider {
    return GlanceDayNightColorProvider(day, night)
}

// Base widget container surface, matching the app's own brand surface tones
// (packages/caravella_core_ui/lib/themes/caravella_themes.dart).
// 10% transparent (0xE6 = 90% alpha) for a subtle frosted look over the
// wallpaper. Safe to do now that the widget actually renders its background at
// all — see the ColorProvider fix below; an earlier attempt at this same
// effect (same 0xE6 value) shipped back when the real bug was full
// transparency on every device, made it impossible to tell intended alpha
// from the bug, and was reverted to fully opaque as a debugging step.
internal val WidgetSurfaceColor = ColorProvider(
    Color(0xE6FFFFFF), // Light mode
    Color(0xE6181A1B), // Dark mode
)

internal val EmphasisTextColor = ColorProvider(
    Color(0xFF1D1A24), // Light mode
    Color(0xFFF4EEFF), // Dark mode
)

// Static palette used when Material You dynamic color isn't available (API <31,
// or the system theme can't be resolved for some reason) — the app's own teal
// brand colors (packages/caravella_core_ui/lib/themes/caravella_themes.dart),
// so the widget matches the rest of the app instead of a generic Material purple.
private val FallbackCtaButtonSurface = ColorProvider(
    Color(0xFF009688), // Light mode (primary)
    Color(0xFF80CBC4), // Dark mode (primary)
)

private val FallbackCtaButtonTextColor = ColorProvider(
    Color(0xFFFFFFFF), // Light mode (onPrimary)
    Color(0xFF003D36), // Dark mode (onPrimary)
)

private val FallbackWeekPillSurface = ColorProvider(
    Color(0xFFB2DFDB), // Light mode (primaryContainer)
    Color(0xFF00695C), // Dark mode (primaryContainer)
)

private val FallbackWeekPillTextColor = ColorProvider(
    Color(0xFF000000), // Light mode (onPrimaryContainer)
    Color(0xFFFFFFFF), // Dark mode (onPrimaryContainer)
)

/** The widget's branded accent surfaces — the 2x2 layout's CTA button and "week" chip. */
internal data class WidgetAccentColors(
    val ctaSurface: ColorProvider,
    val ctaText: ColorProvider,
    val weekPillSurface: ColorProvider,
    val weekPillText: ColorProvider,
)

private val FallbackWidgetAccentColors = WidgetAccentColors(
    ctaSurface = FallbackCtaButtonSurface,
    ctaText = FallbackCtaButtonTextColor,
    weekPillSurface = FallbackWeekPillSurface,
    weekPillText = FallbackWeekPillTextColor,
)

/**
 * Resolves the widget's accent colors from the device's Material You wallpaper
 * palette (Android 12+), so the CTA button and "week" chip follow the user's
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
            weekPillSurface = ColorProvider(day = light.primaryContainer, night = dark.primaryContainer),
            weekPillText = ColorProvider(day = light.onPrimaryContainer, night = dark.onPrimaryContainer),
        )
    } catch (_: Exception) {
        FallbackWidgetAccentColors
    }
}
