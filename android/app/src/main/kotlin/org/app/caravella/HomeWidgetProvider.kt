package io.caravella.egm

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.components.Button
import androidx.glance.appwidget.provideContent
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.defaultWeight
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.dp
import io.caravella.egm.appfunctions.AppFunctionStorageReader
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
                weekValue = "-",
                buttonLabel = context.getString(R.string.widget_select_group),
                buttonIntent = Intent(context, HomeWidgetConfigureActivity::class.java).apply {
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                },
            )
        } else {
            val totals = AppFunctionStorageReader.getWidgetTotals(context, config.groupId)
            val title = totals?.groupTitle ?: config.groupTitle
            val currency = totals?.currency ?: config.groupCurrency
            WidgetUiModel(
                title = title,
                todayValue = totals?.todayTotal?.let { formatAmount(it, currency) } ?: "-",
                weekValue = totals?.weekTotal?.let { formatAmount(it, currency) } ?: "-",
                buttonLabel = context.getString(R.string.widget_quick_add),
                buttonIntent = Intent(context, MainActivity::class.java).apply {
                    action = "io.caravella.egm.ADD_EXPENSE"
                    putExtra("groupId", config.groupId)
                    putExtra("groupTitle", title)
                    flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
                },
            )
        }

        provideContent {
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
                            modifier = GlanceModifier.padding(top = 2.dp),
                        )
                    }
                    Column(modifier = GlanceModifier.defaultWeight()) {
                        Text(text = context.getString(R.string.widget_week_label))
                        Text(
                            text = model.weekValue,
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

    private fun formatAmount(amount: Double, currency: String): String {
        return String.format(Locale.getDefault(), "%.2f %s", amount, currency)
    }
}

private data class WidgetUiModel(
    val title: String,
    val todayValue: String,
    val weekValue: String,
    val buttonLabel: String,
    val buttonIntent: Intent,
)

internal data class WidgetGroupConfig(
    val groupId: String,
    val groupTitle: String,
    val groupCurrency: String,
)

internal object HomeWidgetPrefs {
    private const val PREFS_NAME = "caravella_widget_prefs"
    private const val DEFAULT_CURRENCY = "€"

    private fun keyGroupId(appWidgetId: Int) = "widget_${appWidgetId}_group_id"
    private fun keyGroupTitle(appWidgetId: Int) = "widget_${appWidgetId}_group_title"
    private fun keyGroupCurrency(appWidgetId: Int) = "widget_${appWidgetId}_group_currency"

    fun saveWidgetConfig(
        context: Context,
        appWidgetId: Int,
        groupId: String,
        groupTitle: String,
        groupCurrency: String,
    ) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(keyGroupId(appWidgetId), groupId)
            .putString(keyGroupTitle(appWidgetId), groupTitle)
            .putString(keyGroupCurrency(appWidgetId), groupCurrency)
            .apply()
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
        )
    }

    fun clearWidgetConfig(context: Context, appWidgetId: Int) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .remove(keyGroupId(appWidgetId))
            .remove(keyGroupTitle(appWidgetId))
            .remove(keyGroupCurrency(appWidgetId))
            .apply()
    }
}
