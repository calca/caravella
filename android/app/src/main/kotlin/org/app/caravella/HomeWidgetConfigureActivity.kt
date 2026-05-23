package io.caravella.egm

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.ArrayAdapter
import android.widget.CheckBox
import android.widget.ListView
import android.widget.ProgressBar
import android.widget.TextView
import io.caravella.egm.appfunctions.AppFunctionStorageReader
import kotlin.concurrent.thread

class HomeWidgetConfigureActivity : Activity() {
    private var appWidgetId: Int = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setResult(RESULT_CANCELED)
        setContentView(R.layout.caravella_widget_configure)

        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID,
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        loadGroups()
    }

    private fun loadGroups() {
        val listView = findViewById<ListView>(R.id.widget_config_group_list)
        val progressBar = findViewById<ProgressBar>(R.id.widget_config_progress)
        val emptyView = findViewById<TextView>(R.id.widget_config_empty)
        val groupBackgroundToggle = findViewById<CheckBox>(R.id.widget_config_use_group_background)
        val showGroupNameToggle = findViewById<CheckBox>(R.id.widget_config_show_group_name)

        listView.emptyView = emptyView
        groupBackgroundToggle.isChecked = HomeWidgetPrefs.getUseGroupBackground(this, appWidgetId)
        showGroupNameToggle.isChecked = HomeWidgetPrefs.getShowGroupName(this, appWidgetId)

        thread {
            val groups = AppFunctionStorageReader.getActiveGroups(this)

            runOnUiThread {
                progressBar.visibility = View.GONE

                if (groups.isEmpty()) {
                    emptyView.visibility = View.VISIBLE
                    return@runOnUiThread
                }

                val labels = groups.map { "${it.title} (${it.currency})" }
                listView.adapter = ArrayAdapter(
                    this,
                    android.R.layout.simple_list_item_1,
                    labels,
                )

                listView.setOnItemClickListener { _, _, position, _ ->
                    val selectedGroup = groups[position]

                    HomeWidgetPrefs.saveWidgetConfig(
                        context = this,
                        appWidgetId = appWidgetId,
                        groupId = selectedGroup.id,
                        groupTitle = selectedGroup.title,
                        groupCurrency = selectedGroup.currency,
                        useGroupBackground = groupBackgroundToggle.isChecked,
                        showGroupName = showGroupNameToggle.isChecked,
                    )

                    HomeWidgetProvider.updateAllWidgets(this)

                    val resultIntent = Intent().putExtra(
                        AppWidgetManager.EXTRA_APPWIDGET_ID,
                        appWidgetId,
                    )
                    setResult(RESULT_OK, resultIntent)
                    finish()
                }
            }
        }
    }
}
