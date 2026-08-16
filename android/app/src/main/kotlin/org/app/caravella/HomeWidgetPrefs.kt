package io.caravella.egm

import android.content.Context

internal data class WidgetGroupConfig(
    val groupId: String,
    val groupTitle: String,
    val groupCurrency: String,
    val showGroupName: Boolean,
)

internal object HomeWidgetPrefs {
    private const val PREFS_NAME = "caravella_widget_prefs"
    private const val DEFAULT_CURRENCY = "€"

    private fun keyGroupId(appWidgetId: Int) = "widget_${appWidgetId}_group_id"
    private fun keyGroupTitle(appWidgetId: Int) = "widget_${appWidgetId}_group_title"
    private fun keyGroupCurrency(appWidgetId: Int) = "widget_${appWidgetId}_group_currency"
    private fun keyShowGroupName(appWidgetId: Int) = "widget_${appWidgetId}_show_group_name"

    fun saveWidgetConfig(
        context: Context,
        appWidgetId: Int,
        groupId: String,
        groupTitle: String,
        groupCurrency: String,
        showGroupName: Boolean,
    ) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(keyGroupId(appWidgetId), groupId)
            .putString(keyGroupTitle(appWidgetId), groupTitle)
            .putString(keyGroupCurrency(appWidgetId), groupCurrency)
            .putBoolean(keyShowGroupName(appWidgetId), showGroupName)
            .apply()
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
            showGroupName = getShowGroupName(context, appWidgetId),
        )
    }

    fun clearWidgetConfig(context: Context, appWidgetId: Int) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .remove(keyGroupId(appWidgetId))
            .remove(keyGroupTitle(appWidgetId))
            .remove(keyGroupCurrency(appWidgetId))
            .remove(keyShowGroupName(appWidgetId))
            .apply()
    }
}
