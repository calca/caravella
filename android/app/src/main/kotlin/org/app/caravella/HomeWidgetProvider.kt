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
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.components.Button
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.color.ColorProvider
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.ContentScale
import androidx.glance.layout.Row
import androidx.glance.layout.defaultWeight
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.dp
import androidx.glance.unit.sp
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
                buttonLabel = context.getString(R.string.widget_select_group),
                buttonIntent = Intent(context, HomeWidgetConfigureActivity::class.java).apply {
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                },
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
                buttonLabel = context.getString(R.string.widget_quick_add),
                buttonIntent = Intent(context, MainActivity::class.java).apply {
                    action = "io.caravella.egm.ADD_EXPENSE"
                    putExtra("groupId", config.groupId)
                    putExtra("groupTitle", title)
                    flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
                },
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
            var containerModifier = GlanceModifier.fillMaxSize()
            if (model.useGroupBackground && model.backgroundColor != null) {
                containerModifier = containerModifier.background(
                    ColorProvider(toComposeColor(model.backgroundColor)),
                )
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
                        .padding(12.dp),
                ) {
                    Text(
                        text = model.title,
                        style = TextStyle(fontWeight = FontWeight.Bold),
                        maxLines = 1,
                    )

                    Row(
                        modifier = GlanceModifier
                            .fillMaxWidth()
                            .padding(top = 8.dp),
                    ) {
                        Column(modifier = GlanceModifier.defaultWeight()) {
                            Text(text = context.getString(R.string.widget_today_label))
                            Text(
                                text = model.todayValue,
                                style = TextStyle(fontSize = 18.sp, fontWeight = FontWeight.Bold),
                                modifier = GlanceModifier.padding(top = 2.dp),
                            )
                        }
                        Column(modifier = GlanceModifier.defaultWeight()) {
                            Text(text = context.getString(R.string.widget_group_total_label))
                            Text(
                                text = model.groupTotalValue,
                                style = TextStyle(fontSize = 14.sp),
                                modifier = GlanceModifier.padding(top = 2.dp),
                            )
                        }
                    }

                    Button(
                        text = model.buttonLabel,
                        onClick = actionStartActivity(model.buttonIntent),
                        modifier = GlanceModifier
                            .fillMaxWidth()
                            .padding(top = 12.dp),
                    )
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

private data class WidgetUiModel(
    val title: String,
    val todayValue: String,
    val groupTotalValue: String,
    val buttonLabel: String,
    val buttonIntent: Intent,
    val useGroupBackground: Boolean,
    val backgroundColor: Int?,
    val backgroundImagePath: String?,
)

internal data class WidgetGroupConfig(
    val groupId: String,
    val groupTitle: String,
    val groupCurrency: String,
    val useGroupBackground: Boolean,
)

internal object HomeWidgetPrefs {
    private const val PREFS_NAME = "caravella_widget_prefs"
    private const val DEFAULT_CURRENCY = "€"

    private fun keyGroupId(appWidgetId: Int) = "widget_${appWidgetId}_group_id"
    private fun keyGroupTitle(appWidgetId: Int) = "widget_${appWidgetId}_group_title"
    private fun keyGroupCurrency(appWidgetId: Int) = "widget_${appWidgetId}_group_currency"
    private fun keyUseGroupBackground(appWidgetId: Int) = "widget_${appWidgetId}_use_group_background"

    fun saveWidgetConfig(
        context: Context,
        appWidgetId: Int,
        groupId: String,
        groupTitle: String,
        groupCurrency: String,
        useGroupBackground: Boolean,
    ) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(keyGroupId(appWidgetId), groupId)
            .putString(keyGroupTitle(appWidgetId), groupTitle)
            .putString(keyGroupCurrency(appWidgetId), groupCurrency)
            .putBoolean(keyUseGroupBackground(appWidgetId), useGroupBackground)
            .apply()
    }

    fun getUseGroupBackground(context: Context, appWidgetId: Int): Boolean {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getBoolean(keyUseGroupBackground(appWidgetId), true)
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
        )
    }

    fun clearWidgetConfig(context: Context, appWidgetId: Int) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .remove(keyGroupId(appWidgetId))
            .remove(keyGroupTitle(appWidgetId))
            .remove(keyGroupCurrency(appWidgetId))
            .remove(keyUseGroupBackground(appWidgetId))
            .apply()
    }
}
