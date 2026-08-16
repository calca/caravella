package io.caravella.egm

import android.content.Context

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
