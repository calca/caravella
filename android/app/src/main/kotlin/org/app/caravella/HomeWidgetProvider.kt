package io.caravella.egm

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import androidx.compose.ui.graphics.Color
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.Action
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.action.actionStartActivity as glanceActionStartActivity
import androidx.glance.Button
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.appwidget.updateAll
import androidx.glance.background
import androidx.glance.color.ColorProvider
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
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
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
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val appWidgetId = GlanceAppWidgetManager(context).getAppWidgetId(id)
        val config = HomeWidgetPrefs.getWidgetConfig(context, appWidgetId)

        val model = if (config == null) {
            WidgetUiModel(
                title = context.getString(R.string.widget_unconfigured_title),
                todayValue = "-",
                groupTotalValue = "-",
                showGroupName = true,
                primaryButton = WidgetButton(
                    label = context.getString(R.string.widget_select_group),
                    action = glanceActionStartActivity(
                        Intent(context, HomeWidgetConfigureActivity::class.java).apply {
                            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        },
                    ),
                ),
                secondaryButton = null,
                useGroupBackground = false,
                backgroundColor = null,
                backgroundImagePath = null,
            )
        } else {
            val totals = AppFunctionStorageReader.getWidgetTotals(context, config.groupId)
            val title = totals?.groupTitle ?: config.groupTitle
            val currency = totals?.currency ?: config.groupCurrency
            WidgetUiModel(
                title = title,
                todayValue = totals?.todayTotal?.let { formatAmount(it, currency) } ?: "-",
                groupTotalValue = totals?.groupTotal?.let { formatAmount(it, currency) } ?: "-",
                showGroupName = config.showGroupName,
                primaryButton = WidgetButton(
                    label = context.getString(R.string.widget_quick_add),
                    action = homeWidgetActionStartActivity<MainActivity>(
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
                    ),
                ),
                secondaryButton = WidgetButton(
                    label = context.getString(R.string.widget_open_group),
                    action = homeWidgetActionStartActivity<MainActivity>(
                        context = context,
                        // Keep aligned with AppHomeWidgetService tap parsing.
                        // URI format: caravella://home_widget/open_group?groupId=...&groupTitle=...
                        uri = Uri.Builder()
                            .scheme("caravella")
                            .authority("home_widget")
                            .appendPath("open_group")
                            .appendQueryParameter("groupId", config.groupId)
                            .appendQueryParameter("groupTitle", title)
                            .build(),
                    ),
                ),
                useGroupBackground = config.useGroupBackground,
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
            val baseModifier = GlanceModifier
                .fillMaxSize()
                .padding(WidgetOuterPadding)
                .cornerRadius(WidgetOuterRadius)
            val containerModifier = if (model.useGroupBackground && model.backgroundColor != null) {
                val bgColor = toComposeColor(model.backgroundColor)
                baseModifier.background(
                    ColorProvider(day = bgColor, night = bgColor),
                )
            } else {
                baseModifier.background(DefaultWidgetSurface)
            }

            Box(modifier = containerModifier) {
                if (backgroundImageProvider != null) {
                    Image(
                        provider = backgroundImageProvider,
                        contentDescription = null,
                        contentScale = ContentScale.Crop,
                        modifier = GlanceModifier.fillMaxSize(),
                    )
                }

                Column(
                    modifier = GlanceModifier
                        .fillMaxSize()
                        .padding(WidgetLayerSpacing)
                        .cornerRadius(WidgetInnerRadius)
                        .background(ContentOverlaySurface)
                        .padding(WidgetInnerPadding),
                ) {
                    if (model.showGroupName) {
                        Text(
                            text = model.title,
                            style = TextStyle(
                                color = EmphasisTextColor,
                                fontWeight = FontWeight.Bold,
                                fontSize = WidgetBodyTextSize,
                            ),
                            maxLines = 1,
                        )
                    }

                    Row(
                        modifier = GlanceModifier
                            .fillMaxWidth()
                            .padding(
                                top = if (model.showGroupName) {
                                    WidgetSectionSpacing
                                } else {
                                    WidgetMinimalSpacing
                                },
                            ),
                    ) {
                        Column(modifier = GlanceModifier.defaultWeight()) {
                            Text(
                                text = context.getString(R.string.widget_today_label),
                                style = TextStyle(
                                    color = SecondaryTextColor,
                                    fontSize = WidgetLabelTextSize,
                                ),
                            )
                            Text(
                                text = model.todayValue,
                                style = TextStyle(
                                    color = EmphasisTextColor,
                                    fontSize = WidgetTodayValueTextSize,
                                    fontWeight = FontWeight.Bold,
                                ),
                                modifier = GlanceModifier.padding(top = 2.dp),
                            )
                        }
                        Column(modifier = GlanceModifier.defaultWeight()) {
                            Text(
                                text = context.getString(R.string.widget_group_total_label),
                                style = TextStyle(
                                    color = SecondaryTextColor,
                                    fontSize = WidgetLabelTextSize,
                                ),
                            )
                            Text(
                                text = model.groupTotalValue,
                                style = TextStyle(
                                    color = EmphasisTextColor,
                                    fontSize = WidgetBodyTextSize,
                                ),
                                modifier = GlanceModifier.padding(top = 2.dp),
                            )
                        }
                    }

                    if (model.secondaryButton == null) {
                        Button(
                            text = model.primaryButton.label,
                            onClick = model.primaryButton.action,
                            modifier = GlanceModifier
                                .fillMaxWidth()
                                .padding(top = 12.dp),
                        )
                    } else {
                        Row(
                            modifier = GlanceModifier
                                .fillMaxWidth()
                                .padding(top = 12.dp),
                        ) {
                            Button(
                                text = model.primaryButton.label,
                                onClick = model.primaryButton.action,
                                modifier = GlanceModifier
                                    .defaultWeight()
                                    .padding(end = 4.dp),
                            )
                            Button(
                                text = model.secondaryButton.label,
                                onClick = model.secondaryButton.action,
                                modifier = GlanceModifier
                                    .defaultWeight()
                                    .padding(start = 4.dp),
                            )
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

private val WidgetOuterPadding = 4.dp
private val WidgetLayerSpacing = 10.dp
private val WidgetInnerPadding = 12.dp
private val WidgetSectionSpacing = 10.dp
private val WidgetMinimalSpacing = 2.dp
private val WidgetOuterRadius = 24.dp
private val WidgetInnerRadius = 20.dp
private val WidgetBodyTextSize = 15.sp
private val WidgetLabelTextSize = 12.sp
private val WidgetTodayValueTextSize = 22.sp

// Default widget container surface when group-based background is disabled.
// Colors are aligned with a soft Material-like neutral surface for baseline readability.
private val DefaultWidgetSurface = ColorProvider(
    Color(0xFFF6F4FA), // Light mode
    Color(0xFF1F1D25), // Dark mode
)

// Glass-like overlay above image/color backgrounds for better text readability.
// Uses consistent ~80% opacity in both themes for predictable legibility.
// This is layered on top of custom group image/color backgrounds.
private val ContentOverlaySurface = ColorProvider(
    Color(0xCCFFFFFF), // Light mode (80% white)
    Color(0xCC000000), // Dark mode (80% black)
)

private val EmphasisTextColor = ColorProvider(
    Color(0xFF1D1A24), // Light mode
    Color(0xFFF4EEFF), // Dark mode
)

private val SecondaryTextColor = ColorProvider(
    Color(0xFF5F5A68), // Light mode
    Color(0xFFC8C2D2), // Dark mode
)

private data class WidgetUiModel(
    val title: String,
    val todayValue: String,
    val groupTotalValue: String,
    val showGroupName: Boolean,
    val primaryButton: WidgetButton,
    val secondaryButton: WidgetButton?,
    val useGroupBackground: Boolean,
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
)

internal object HomeWidgetPrefs {
    private const val PREFS_NAME = "caravella_widget_prefs"
    private const val DEFAULT_CURRENCY = "€"

    private fun keyGroupId(appWidgetId: Int) = "widget_${appWidgetId}_group_id"
    private fun keyGroupTitle(appWidgetId: Int) = "widget_${appWidgetId}_group_title"
    private fun keyGroupCurrency(appWidgetId: Int) = "widget_${appWidgetId}_group_currency"
    private fun keyUseGroupBackground(appWidgetId: Int) = "widget_${appWidgetId}_use_group_background"
    private fun keyShowGroupName(appWidgetId: Int) = "widget_${appWidgetId}_show_group_name"

    fun saveWidgetConfig(
        context: Context,
        appWidgetId: Int,
        groupId: String,
        groupTitle: String,
        groupCurrency: String,
        useGroupBackground: Boolean,
        showGroupName: Boolean,
    ) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(keyGroupId(appWidgetId), groupId)
            .putString(keyGroupTitle(appWidgetId), groupTitle)
            .putString(keyGroupCurrency(appWidgetId), groupCurrency)
            .putBoolean(keyUseGroupBackground(appWidgetId), useGroupBackground)
            .putBoolean(keyShowGroupName(appWidgetId), showGroupName)
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
            .apply()
    }
}
