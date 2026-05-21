package io.caravella.egm

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import io.caravella.egm.appfunctions.AppFunctionStorageReader
import java.util.Locale
import kotlin.concurrent.thread

class HomeWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        updateAllWidgets(context)
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
        appWidgetIds.forEach { appWidgetId ->
            HomeWidgetPrefs.clearWidgetConfig(context, appWidgetId)
        }
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

    companion object {
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val views = RemoteViews(context.packageName, R.layout.caravella_widget)
            val config = HomeWidgetPrefs.getWidgetConfig(context, appWidgetId)

            if (config == null) {
                setUnconfiguredState(context, appWidgetId, views)
                appWidgetManager.updateAppWidget(appWidgetId, views)
                return
            }

            val today = AppFunctionStorageReader.getTodayTotal(context, config.groupId)
            val week = AppFunctionStorageReader.getWeekTotal(context, config.groupId)

            if (today == null || week == null) {
                views.setTextViewText(
                    R.id.widget_group_title,
                    config.groupTitle,
                )
                views.setTextViewText(R.id.widget_today_value, "-")
                views.setTextViewText(R.id.widget_week_value, "-")
                views.setTextViewText(
                    R.id.widget_quick_add_button,
                    context.getString(R.string.widget_quick_add),
                )
                views.setBoolean(R.id.widget_quick_add_button, "setEnabled", true)
                views.setOnClickPendingIntent(
                    R.id.widget_quick_add_button,
                    createQuickAddIntent(context, appWidgetId, config.groupId, config.groupTitle),
                )
                appWidgetManager.updateAppWidget(appWidgetId, views)
                return
            }

            views.setTextViewText(R.id.widget_group_title, today.groupTitle)
            views.setTextViewText(
                R.id.widget_today_value,
                formatAmount(today.todayTotal, today.currency),
            )
            views.setTextViewText(
                R.id.widget_week_value,
                formatAmount(week.weekTotal, week.currency),
            )
            views.setTextViewText(
                R.id.widget_quick_add_button,
                context.getString(R.string.widget_quick_add),
            )
            views.setBoolean(R.id.widget_quick_add_button, "setEnabled", true)
            views.setOnClickPendingIntent(
                R.id.widget_quick_add_button,
                createQuickAddIntent(
                    context,
                    appWidgetId,
                    today.groupId,
                    today.groupTitle,
                ),
            )

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        fun updateAllWidgets(context: Context) {
            val applicationContext = context.applicationContext
            thread {
                val appWidgetManager = AppWidgetManager.getInstance(applicationContext)
                val widgetIds = appWidgetManager.getAppWidgetIds(
                    ComponentName(applicationContext, HomeWidgetProvider::class.java),
                )
                widgetIds.forEach { appWidgetId ->
                    updateAppWidget(applicationContext, appWidgetManager, appWidgetId)
                }
            }
        }

        private fun setUnconfiguredState(
            context: Context,
            appWidgetId: Int,
            views: RemoteViews,
        ) {
            views.setTextViewText(
                R.id.widget_group_title,
                context.getString(R.string.widget_unconfigured_title),
            )
            views.setTextViewText(R.id.widget_today_value, "-")
            views.setTextViewText(R.id.widget_week_value, "-")
            views.setTextViewText(
                R.id.widget_quick_add_button,
                context.getString(R.string.widget_select_group),
            )
            views.setBoolean(R.id.widget_quick_add_button, "setEnabled", true)
            views.setOnClickPendingIntent(
                R.id.widget_quick_add_button,
                createConfigureIntent(context, appWidgetId),
            )
        }

        private fun createQuickAddIntent(
            context: Context,
            appWidgetId: Int,
            groupId: String,
            groupTitle: String,
        ): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                action = "io.caravella.egm.ADD_EXPENSE"
                putExtra("groupId", groupId)
                putExtra("groupTitle", groupTitle)
                flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
            }
            return PendingIntent.getActivity(
                context,
                appWidgetId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }

        private fun createConfigureIntent(
            context: Context,
            appWidgetId: Int,
        ): PendingIntent {
            val intent = Intent(context, HomeWidgetConfigureActivity::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            return PendingIntent.getActivity(
                context,
                appWidgetId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }

        private fun formatAmount(amount: Double, currency: String): String {
            return String.format(Locale.getDefault(), "%.2f %s", amount, currency)
        }
    }
}

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
