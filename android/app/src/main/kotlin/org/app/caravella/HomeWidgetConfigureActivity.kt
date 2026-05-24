package io.caravella.egm

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material3.Button
import androidx.compose.material3.Checkbox
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Tab
import androidx.compose.material3.TabRow
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import io.caravella.egm.appfunctions.AppFunctionStorageReader
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class HomeWidgetConfigureActivity : ComponentActivity() {
    private var appWidgetId: Int = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setResult(Activity.RESULT_CANCELED)

        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID,
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        setContent {
            MaterialTheme {
                HomeWidgetConfigureScreen(
                    appWidgetId = appWidgetId,
                    onConfigSaved = { groupId, groupTitle, groupCurrency, useGroupBackground, showGroupName ->
                        HomeWidgetPrefs.saveWidgetConfig(
                            context = this,
                            appWidgetId = appWidgetId,
                            groupId = groupId,
                            groupTitle = groupTitle,
                            groupCurrency = groupCurrency,
                            useGroupBackground = useGroupBackground,
                            showGroupName = showGroupName,
                        )

                        HomeWidgetProvider.updateAllWidgets(this)

                        val resultIntent = Intent().putExtra(
                            AppWidgetManager.EXTRA_APPWIDGET_ID,
                            appWidgetId,
                        )
                        setResult(Activity.RESULT_OK, resultIntent)
                        finish()
                    },
                )
            }
        }
    }
}

private sealed interface HomeWidgetConfigureUiState {
    data object Loading : HomeWidgetConfigureUiState
    data class Loaded(val groups: List<AppFunctionStorageReader.GroupSummary>) : HomeWidgetConfigureUiState
}

private enum class HomeWidgetConfigureTab {
    Group,
    Options,
}

@Composable
private fun HomeWidgetConfigureScreen(
    appWidgetId: Int,
    onConfigSaved: (String, String, String, Boolean, Boolean) -> Unit,
) {
    val context = LocalContext.current
    var uiState by remember { mutableStateOf<HomeWidgetConfigureUiState>(HomeWidgetConfigureUiState.Loading) }
    var selectedTab by remember { mutableStateOf(HomeWidgetConfigureTab.Group) }
    var selectedGroupId by remember {
        mutableStateOf(HomeWidgetPrefs.getWidgetConfig(context, appWidgetId)?.groupId)
    }
    var useGroupBackground by remember {
        mutableStateOf(HomeWidgetPrefs.getUseGroupBackground(context, appWidgetId))
    }
    var showGroupName by remember {
        mutableStateOf(HomeWidgetPrefs.getShowGroupName(context, appWidgetId))
    }

    LaunchedEffect(Unit) {
        val groups = withContext(Dispatchers.IO) { AppFunctionStorageReader.getActiveGroups(context) }
        uiState = HomeWidgetConfigureUiState.Loaded(groups)
    }

    val selectedGroup = (uiState as? HomeWidgetConfigureUiState.Loaded)
        ?.groups
        ?.firstOrNull { it.id == selectedGroupId }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Text(
            text = context.getString(R.string.widget_config_title),
            style = MaterialTheme.typography.titleMedium,
        )

        TabRow(selectedTabIndex = selectedTab.ordinal) {
            Tab(
                selected = selectedTab == HomeWidgetConfigureTab.Group,
                onClick = { selectedTab = HomeWidgetConfigureTab.Group },
                text = { Text(text = context.getString(R.string.widget_config_tab_group)) },
            )
            Tab(
                selected = selectedTab == HomeWidgetConfigureTab.Options,
                onClick = { selectedTab = HomeWidgetConfigureTab.Options },
                text = { Text(text = context.getString(R.string.widget_config_tab_options)) },
            )
        }

        when (selectedTab) {
            HomeWidgetConfigureTab.Group -> {
                when (val state = uiState) {
                    HomeWidgetConfigureUiState.Loading -> {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .weight(1f),
                            contentAlignment = Alignment.Center,
                        ) {
                            CircularProgressIndicator()
                        }
                    }

                    is HomeWidgetConfigureUiState.Loaded -> {
                        if (state.groups.isEmpty()) {
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .weight(1f),
                                contentAlignment = Alignment.Center,
                            ) {
                                Text(text = context.getString(R.string.widget_config_empty))
                            }
                        } else {
                            LazyColumn(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .weight(1f),
                            ) {
                                itemsIndexed(state.groups, key = { _, group -> group.id }) { index, group ->
                                    val isSelected = selectedGroupId == group.id
                                    Column(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .semantics {
                                                role = Role.Button
                                                contentDescription = context.getString(
                                                    R.string.widget_config_select_group_a11y,
                                                    group.title,
                                                    group.currency,
                                                )
                                            }
                                            .clickable { selectedGroupId = group.id }
                                            .padding(vertical = 12.dp),
                                    ) {
                                        Text(
                                            text = group.title,
                                            style = MaterialTheme.typography.bodyLarge,
                                            color = if (isSelected) {
                                                MaterialTheme.colorScheme.primary
                                            } else {
                                                MaterialTheme.colorScheme.onSurface
                                            },
                                        )
                                        Text(
                                            text = context.getString(
                                                R.string.widget_config_currency_label,
                                                group.currency,
                                            ),
                                            style = MaterialTheme.typography.bodyMedium,
                                        )
                                        if (isSelected) {
                                            Text(
                                                text = context.getString(R.string.widget_config_selected),
                                                style = MaterialTheme.typography.bodySmall,
                                                color = MaterialTheme.colorScheme.primary,
                                            )
                                        }
                                    }
                                    if (index < state.groups.lastIndex) {
                                        HorizontalDivider()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            HomeWidgetConfigureTab.Options -> {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    WidgetConfigToggleRow(
                        label = context.getString(R.string.widget_config_use_group_background),
                        checked = useGroupBackground,
                        onCheckedChange = { useGroupBackground = it },
                    )

                    WidgetConfigToggleRow(
                        label = context.getString(R.string.widget_config_show_group_name),
                        checked = showGroupName,
                        onCheckedChange = { showGroupName = it },
                    )
                }
            }
        }

        Button(
            onClick = {
                selectedGroup?.let { group ->
                    onConfigSaved(
                        group.id,
                        group.title,
                        group.currency,
                        useGroupBackground,
                        showGroupName,
                    )
                }
            },
            enabled = selectedGroup != null,
            modifier = Modifier.fillMaxWidth(),
        ) {
            val buttonText = if (selectedGroup == null) {
                context.getString(R.string.widget_config_save_disabled)
            } else {
                context.getString(R.string.widget_config_save)
            }
            Text(text = buttonText)
        }
    }
}

@Composable
private fun WidgetConfigToggleRow(
    label: String,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit,
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onCheckedChange(!checked) }
            .padding(vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Checkbox(
            checked = checked,
            onCheckedChange = onCheckedChange,
        )
        Text(
            text = label,
            modifier = Modifier.padding(start = 8.dp),
            style = MaterialTheme.typography.bodyMedium,
        )
    }
}
