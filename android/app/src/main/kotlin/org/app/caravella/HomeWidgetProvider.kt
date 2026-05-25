package io.caravella.egm

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.LocalSize
import androidx.glance.action.Action
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.actionStartActivity as glanceActionStartActivity
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.appwidget.updateAll
import androidx.glance.background
import androidx.glance.unit.ColorProvider
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.ContentScale
import androidx.glance.layout.Row
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import es.antonborri.home_widget.actionStartActivity as homeWidgetActionStartActivity
import io.caravella.egm.appfunctions.AppFunctionStorageReader
import java.io.File
import java.io.IOException
import java.util.Locale
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class HomeWidgetProvider : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = CaravellaHomeWidget

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        updateAllWidgets(context)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            Intent.ACTION_DATE_CHANGED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
            AppWidgetManager.ACTION_APPWIDGET_UPDATE,
            -> updateAllWidgets(context)
        }
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
        appWidgetIds.forEach { appWidgetId ->
            HomeWidgetPrefs.clearWidgetConfig(context, appWidgetId)
        }
    }

    companion object {
        fun updateAllWidgets(context: Context) {
            val applicationContext = context.applicationContext
            CoroutineScope(Dispatchers.IO).launch {
                CaravellaHomeWidget.updateAll(applicationContext)
            }
        }
    }
}

private object CaravellaHomeWidget : GlanceAppWidget() {
    // Responsive size breakpoints for adaptive layout
    private val SMALL = DpSize(57.dp, 57.dp)
    private val MEDIUM = DpSize(130.dp, 130.dp)
    private val WIDE = DpSize(200.dp, 130.dp)

    override val sizeMode = SizeMode.Responsive(
        setOf(SMALL, MEDIUM, WIDE),
    )

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val appWidgetId = GlanceAppWidgetManager(context).getAppWidgetId(id)
        val config = HomeWidgetPrefs.getWidgetConfig(context, appWidgetId)

        val model = if (config == null) {
            WidgetUiModel(
                title = context.getString(R.string.widget_unconfigured_title),
                todayValue = "-",
                groupTotalValue = "-",
                showGroupName = true,
                ctaButton = WidgetButton(
                    label = context.getString(R.string.widget_select_group),
                    action = glanceActionStartActivity(
                        Intent(context, HomeWidgetConfigureActivity::class.java).apply {
                            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        },
                    ),
                ),
                tapAction = null,
                useGroupBackground = false,
                backgroundTransparency = 0,
                backgroundColor = null,
                backgroundImagePath = null,
            )
        } else {
            val totals = AppFunctionStorageReader.getWidgetTotals(context, config.groupId)
            val title = totals?.groupTitle ?: config.groupTitle
            val currency = totals?.currency ?: config.groupCurrency
            val addExpenseAction = homeWidgetActionStartActivity<MainActivity>(
                context = context,
                // Keep aligned with AppHomeWidgetService tap parsing.
                // URI format: caravella://home_widget/add_expense?groupId=...&groupTitle=...
                uri = Uri.Builder()
                    .scheme("caravella")
                    .authority("home_widget")
                    .appendPath("add_expense")
                    .appendQueryParameter("groupId", config.groupId)
                    .appendQueryParameter("groupTitle", title)
                    .build(),
            )
            WidgetUiModel(
                title = title,
                // Default to 0.0 when totals are unavailable (e.g. first load before
                // any expenses exist) so the widget always shows a formatted amount
                // instead of a placeholder dash.
                todayValue = formatAmount(totals?.todayTotal ?: 0.0, currency),
                groupTotalValue = formatAmount(totals?.groupTotal ?: 0.0, currency),
                showGroupName = config.showGroupName,
                ctaButton = WidgetButton(
                    label = "+",
                    action = addExpenseAction,
                ),
                tapAction = addExpenseAction,
                useGroupBackground = config.useGroupBackground,
                backgroundTransparency = config.backgroundTransparency,
                backgroundColor = if (config.useGroupBackground) totals?.groupColor else null,
                backgroundImagePath = if (config.useGroupBackground) {
                    totals?.groupBackgroundImagePath
                } else {
                    null
                },
            )
        }

        val backgroundImageProvider = if (model.useGroupBackground) {
            loadImageProvider(context, model.backgroundImagePath)
        } else {
            null
        }

        provideContent {
            val size = LocalSize.current
            val isCompact = size.width < 130.dp || size.height < 130.dp
            val isWide = size.width >= 200.dp

            // Always use white as the base background color. Transparency setting
            // controls how much of the white shows through (or how opaque the overlay is).
            val baseModifier = GlanceModifier
                .fillMaxSize()
                .cornerRadius(WidgetOuterRadius)
                .background(ColorProvider(Color.White, Color.White))
            val clickableContainerModifier = if (model.tapAction != null) {
                baseModifier.clickable(model.tapAction)
            } else {
                baseModifier
            }

            Box(modifier = clickableContainerModifier) {
                if (backgroundImageProvider != null) {
                    // Image positioned above white base; the overlay on top
                    // provides readability by making the image semi-transparent.
                    Image(
                        provider = backgroundImageProvider,
                        contentDescription = null,
                        contentScale = ContentScale.Crop,
                        modifier = GlanceModifier
                            .fillMaxSize()
                            .cornerRadius(WidgetOuterRadius),
                    )
                    // Semi-transparent white overlay above image for text readability.
                    Box(
                        modifier = GlanceModifier
                            .fillMaxSize()
                            .cornerRadius(WidgetOuterRadius)
                            .background(contentOverlaySurface(model.backgroundTransparency)),
                    ) {}
                } else if (model.useGroupBackground && model.backgroundColor != null) {
                    val bgColor = toComposeColor(model.backgroundColor)
                    Box(
                        modifier = GlanceModifier
                            .fillMaxSize()
                            .cornerRadius(WidgetOuterRadius)
                            .background(ColorProvider(day = bgColor, night = bgColor)),
                    ) {}
                }

                if (isCompact) {
                    // Compact 1x1 layout: just today value centered
                    val overlayModifier = if (model.backgroundTransparency >= 100) {
                        GlanceModifier.fillMaxSize().padding(WidgetCompactPadding)
                    } else {
                        GlanceModifier
                            .fillMaxSize()
                            .cornerRadius(WidgetOuterRadius)
                            .background(contentOverlaySurface(model.backgroundTransparency))
                            .padding(WidgetCompactPadding)
                    }
                    Box(
                        modifier = overlayModifier,
                        contentAlignment = Alignment.Center,
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            if (model.showGroupName) {
                                Text(
                                    text = model.title,
                                    style = TextStyle(
                                        color = EmphasisTextColor,
                                        fontWeight = FontWeight.Bold,
                                        fontSize = WidgetLabelTextSize,
                                    ),
                                    maxLines = 1,
                                )
                            }
                            Text(
                                text = model.todayValue,
                                style = TextStyle(
                                    color = EmphasisTextColor,
                                    fontSize = WidgetCompactValueTextSize,
                                    fontWeight = FontWeight.Bold,
                                ),
                                maxLines = 1,
                            )
                        }
                    }
                } else {
                    // Standard layout: content overlays on top of background
                    val overlayModifier = GlanceModifier
                        .fillMaxSize()
                        .padding(WidgetInnerPadding)

                    Box(modifier = overlayModifier) {
                        Column(
                            modifier = GlanceModifier.fillMaxSize(),
                        ) {
                            // First row: "Total Spent" label + "today: $total" chip
                            Row(
                                modifier = GlanceModifier.fillMaxWidth(),
                            ) {
                                Text(
                                    text = context.getString(R.string.widget_total_spent_label),
                                    style = TextStyle(
                                        color = EmphasisTextColor,
                                        fontWeight = FontWeight.Bold,
                                        fontSize = WidgetBodyTextSize,
                                    ),
                                    maxLines = 1,
                                )
                                Box(
                                    modifier = GlanceModifier
                                        .padding(start = 8.dp)
                                        .cornerRadius(WidgetTodayPillRadius)
                                        .background(WidgetTodayPillSurface)
                                        .padding(
                                            start = WidgetTodayPillHorizontalPadding,
                                            top = WidgetTodayPillVerticalPadding,
                                            end = WidgetTodayPillHorizontalPadding,
                                            bottom = WidgetTodayPillVerticalPadding,
                                        ),
                                ) {
                                    Text(
                                        text = "${context.getString(R.string.widget_today_label)} ${model.todayValue}",
                                        style = TextStyle(
                                            color = WidgetTodayPillTextColor,
                                            fontSize = WidgetLabelTextSize,
                                            fontWeight = FontWeight.Bold,
                                        ),
                                    )
                                }
                            }

                            if (model.showGroupName) {
                                Text(
                                    text = model.title,
                                    style = TextStyle(
                                        color = SecondaryTextColor,
                                        fontSize = WidgetLabelTextSize,
                                    ),
                                    maxLines = 1,
                                    modifier = GlanceModifier.padding(top = WidgetMinimalSpacing),
                                )
                            }

                            if (isWide) {
                                // Wide layout: group total displayed
                                Text(
                                    text = model.groupTotalValue,
                                    style = TextStyle(
                                        color = EmphasisTextColor,
                                        fontSize = WidgetGroupTotalValueTextSize,
                                        fontWeight = FontWeight.Bold,
                                    ),
                                    modifier = GlanceModifier.padding(top = WidgetSectionSpacing),
                                )
                            }
                        }

                        // CTA + button: always bottom-right, square with rounded corners
                        if (model.ctaButton != null) {
                            Box(
                                modifier = GlanceModifier.fillMaxSize(),
                                contentAlignment = Alignment.BottomEnd,
                            ) {
                                Box(
                                    modifier = GlanceModifier
                                        .cornerRadius(WidgetCtaButtonRadius)
                                        .background(WidgetCtaButtonSurface)
                                        .padding(WidgetCtaButtonPadding)
                                        .clickable(model.ctaButton.action),
                                    contentAlignment = Alignment.Center,
                                ) {
                                    Text(
                                        text = model.ctaButton.label,
                                        style = TextStyle(
                                            color = WidgetCtaButtonTextColor,
                                            fontSize = WidgetCtaButtonTextSize,
                                            fontWeight = FontWeight.Bold,
                                        ),
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private fun formatAmount(amount: Double, currency: String): String {
        return String.format(Locale.getDefault(), "%.2f %s", amount, currency)
    }

    private fun toComposeColor(colorValue: Int): Color = Color(colorValue.toUInt().toULong())

    private fun loadImageProvider(context: Context, path: String?): ImageProvider? {
        if (path.isNullOrBlank()) return null
        return try {
            val bitmap = loadBitmap(context, path) ?: return null
            ImageProvider(bitmap)
        } catch (_: Exception) {
            null
        }
    }

    private fun loadBitmap(context: Context, path: String): Bitmap? {
        return if (path.startsWith("content://")) {
            try {
                context.contentResolver.openInputStream(Uri.parse(path)).use { input ->
                    input?.let { BitmapFactory.decodeStream(it) }
                }
            } catch (_: IOException) {
                null
            }
        } else {
            val file = File(path)
            if (!file.exists()) return null
            BitmapFactory.decodeFile(file.absolutePath)
        }
    }
}

private val WidgetLayerSpacing = 10.dp
private val WidgetInnerPadding = 12.dp
private val WidgetCompactPadding = 6.dp
private val WidgetSectionSpacing = 10.dp
private val WidgetMinimalSpacing = 2.dp
private val WidgetOuterRadius = 24.dp
private val WidgetInnerRadius = 20.dp
private val WidgetBodyTextSize = 15.sp
private val WidgetLabelTextSize = 12.sp
private val WidgetTodayValueTextSize = 18.sp
private val WidgetCompactValueTextSize = 16.sp
private val WidgetGroupTotalValueTextSize = 22.sp
private val WidgetTodayPillRadius = 16.dp
private val WidgetTodayPillHorizontalPadding = 8.dp
private val WidgetTodayPillVerticalPadding = 2.dp
private val WidgetCtaButtonRadius = 16.dp
private val WidgetCtaButtonPadding = 14.dp
private val WidgetCtaButtonTextSize = 24.sp

/**
 * Creates a [ColorProvider] that resolves to [day] in light mode and [night] in dark mode.
 * Replaces the removed `androidx.glance.color.ColorProvider(day, night)` factory.
 */
private fun ColorProvider(day: Color, night: Color): ColorProvider {
    return DayNightColorProvider(day, night)
}

private data class DayNightColorProvider(val day: Color, val night: Color) : ColorProvider {
    override fun getColor(context: Context): Color {
        val nightMode = context.resources.configuration.uiMode and
            android.content.res.Configuration.UI_MODE_NIGHT_MASK
        return if (nightMode == android.content.res.Configuration.UI_MODE_NIGHT_YES) night else day
    }
}

// Default widget container surface when group-based background is disabled.
// Glass-like overlay above image/color backgrounds for better text readability.
// Uses consistent ~80% opacity in both themes for predictable legibility.
// This is layered on top of custom group image/color backgrounds.
/**
 * Returns the content overlay surface color with alpha based on the transparency level.
 * transparency=0 → full overlay (0xCC alpha ≈ 80%), transparency=100 → no overlay (fully transparent).
 */
private fun contentOverlaySurface(transparency: Int): ColorProvider {
    // Base alpha is 0xCC (204) at transparency=0; linearly decreases to 0x00 at transparency=100.
    val clampedTransparency = transparency.coerceIn(0, 100)
    val alpha = ((100 - clampedTransparency) * 0xCC / 100.0).toInt()
    val alphaHex = alpha.toLong()
    return ColorProvider(
        Color((alphaHex shl 24) or 0xFFFFFF),  // Light mode (white overlay)
        Color((alphaHex shl 24) or 0x000000),  // Dark mode (black overlay)
    )
}

private val EmphasisTextColor = ColorProvider(
    Color(0xFF1D1A24), // Light mode
    Color(0xFFF4EEFF), // Dark mode
)

private val SecondaryTextColor = ColorProvider(
    Color(0xFF5F5A68), // Light mode
    Color(0xFFC8C2D2), // Dark mode
)

private val WidgetTodayPillSurface = ColorProvider(
    Color(0x80E1D8F8), // Light mode – 50% opacity
    Color(0x804D3B73), // Dark mode – 50% opacity
)

private val WidgetTodayPillTextColor = ColorProvider(
    Color(0xFF2E1B52), // Light mode
    Color(0xFFF3ECFF), // Dark mode
)

private val WidgetCtaButtonSurface = ColorProvider(
    Color(0xFF6750A4), // Light mode (Material primary)
    Color(0xFFD0BCFF), // Dark mode
)

private val WidgetCtaButtonTextColor = ColorProvider(
    Color(0xFFFFFFFF), // Light mode
    Color(0xFF381E72), // Dark mode
)

private data class WidgetUiModel(
    val title: String,
    val todayValue: String,
    val groupTotalValue: String,
    val showGroupName: Boolean,
    val ctaButton: WidgetButton?,
    val tapAction: Action?,
    val useGroupBackground: Boolean,
    val backgroundTransparency: Int,
    val backgroundColor: Int?,
    val backgroundImagePath: String?,
)

// Label + action pair used by widget primary/secondary buttons.
private data class WidgetButton(
    val label: String,
    val action: Action,
)

internal data class WidgetGroupConfig(
    val groupId: String,
    val groupTitle: String,
    val groupCurrency: String,
    val useGroupBackground: Boolean,
    val showGroupName: Boolean,
    val backgroundTransparency: Int,
)

internal object HomeWidgetPrefs {
    private const val PREFS_NAME = "caravella_widget_prefs"
    private const val DEFAULT_CURRENCY = "€"
    private const val DEFAULT_TRANSPARENCY = 25

    private fun keyGroupId(appWidgetId: Int) = "widget_${appWidgetId}_group_id"
    private fun keyGroupTitle(appWidgetId: Int) = "widget_${appWidgetId}_group_title"
    private fun keyGroupCurrency(appWidgetId: Int) = "widget_${appWidgetId}_group_currency"
    private fun keyUseGroupBackground(appWidgetId: Int) = "widget_${appWidgetId}_use_group_background"
    private fun keyShowGroupName(appWidgetId: Int) = "widget_${appWidgetId}_show_group_name"
    private fun keyBackgroundTransparency(appWidgetId: Int) = "widget_${appWidgetId}_background_transparency"

    fun saveWidgetConfig(
        context: Context,
        appWidgetId: Int,
        groupId: String,
        groupTitle: String,
        groupCurrency: String,
        useGroupBackground: Boolean,
        showGroupName: Boolean,
        backgroundTransparency: Int,
    ) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(keyGroupId(appWidgetId), groupId)
            .putString(keyGroupTitle(appWidgetId), groupTitle)
            .putString(keyGroupCurrency(appWidgetId), groupCurrency)
            .putBoolean(keyUseGroupBackground(appWidgetId), useGroupBackground)
            .putBoolean(keyShowGroupName(appWidgetId), showGroupName)
            .putInt(keyBackgroundTransparency(appWidgetId), backgroundTransparency)
            .apply()
    }

    fun getUseGroupBackground(context: Context, appWidgetId: Int): Boolean {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getBoolean(keyUseGroupBackground(appWidgetId), true)
    }

    fun getShowGroupName(context: Context, appWidgetId: Int): Boolean {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getBoolean(keyShowGroupName(appWidgetId), true)
    }

    fun getBackgroundTransparency(context: Context, appWidgetId: Int): Int {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getInt(keyBackgroundTransparency(appWidgetId), DEFAULT_TRANSPARENCY)
    }

    fun getWidgetConfig(context: Context, appWidgetId: Int): WidgetGroupConfig? {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val groupId = prefs.getString(keyGroupId(appWidgetId), null) ?: return null
        val groupTitle = prefs.getString(keyGroupTitle(appWidgetId), null) ?: return null
        val groupCurrency = prefs.getString(keyGroupCurrency(appWidgetId), DEFAULT_CURRENCY)
            ?: DEFAULT_CURRENCY
        return WidgetGroupConfig(
            groupId = groupId,
            groupTitle = groupTitle,
            groupCurrency = groupCurrency,
            useGroupBackground = getUseGroupBackground(context, appWidgetId),
            showGroupName = getShowGroupName(context, appWidgetId),
            backgroundTransparency = getBackgroundTransparency(context, appWidgetId),
        )
    }

    fun clearWidgetConfig(context: Context, appWidgetId: Int) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .remove(keyGroupId(appWidgetId))
            .remove(keyGroupTitle(appWidgetId))
            .remove(keyGroupCurrency(appWidgetId))
            .remove(keyUseGroupBackground(appWidgetId))
            .remove(keyShowGroupName(appWidgetId))
            .remove(keyBackgroundTransparency(appWidgetId))
            .apply()
    }
}
