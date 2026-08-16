package io.caravella.egm

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.selection.toggleable
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.Button
import androidx.compose.material3.Checkbox
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Tab
import androidx.compose.material3.TabRow
import androidx.compose.material3.Text
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import io.caravella.egm.appfunctions.AppFunctionStorageReader
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

// The app's own teal brand colors (packages/caravella_core_ui/lib/themes/caravella_themes.dart),
// used as a fallback ColorScheme when Material You dynamic color isn't available
// (API <31), so the widget's config screen matches the rest of the app instead of
// falling back to Compose Material3's generic purple baseline.
private val CaravellaLightColorScheme = lightColorScheme(
    primary = Color(0xFF009688),
    onPrimary = Color(0xFFFFFFFF),
    primaryContainer = Color(0xFFB2DFDB),
    onPrimaryContainer = Color(0xFF000000),
    surface = Color(0xFFFFFFFF),
    onSurface = Color(0xFF000000),
)

private val CaravellaDarkColorScheme = darkColorScheme(
    primary = Color(0xFF80CBC4),
    onPrimary = Color(0xFF003D36),
    primaryContainer = Color(0xFF00695C),
    onPrimaryContainer = Color(0xFFFFFFFF),
    surface = Color(0xFF181A1B),
    onSurface = Color(0xFFEAEAEA),
)

@Composable
private fun caravellaColorScheme(darkTheme: Boolean): ColorScheme {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
        return if (darkTheme) CaravellaDarkColorScheme else CaravellaLightColorScheme
    }
    val context = LocalContext.current
    return try {
        if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
    } catch (_: Exception) {
        if (darkTheme) CaravellaDarkColorScheme else CaravellaLightColorScheme
    }
}

class HomeWidgetConfigureActivity : ComponentActivity() {
    private var appWidgetId: Int = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
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
            MaterialTheme(colorScheme = caravellaColorScheme(darkTheme = isSystemInDarkTheme())) {
                Scaffold { innerPadding ->
                    HomeWidgetConfigureScreen(
                        appWidgetId = appWidgetId,
                        modifier = Modifier.padding(innerPadding),
                        onConfigSaved = { groupId, groupTitle, groupCurrency, showGroupName ->
                            HomeWidgetPrefs.saveWidgetConfig(
                                context = this,
                                appWidgetId = appWidgetId,
                                groupId = groupId,
                                groupTitle = groupTitle,
                                groupCurrency = groupCurrency,
                                showGroupName = showGroupName,
                            )

                            // Awaited so the widget is guaranteed refreshed before finish() —
                            // the fire-and-forget variant used elsewhere can otherwise lose
                            // the race when this screen was reached via the widget's own
                            // in-app CTA rather than the system's configure contract, which
                            // has no automatic post-configure refresh to fall back on.
                            HomeWidgetProvider.updateAllWidgetsAndAwait(this)

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
    modifier: Modifier = Modifier,
    onConfigSaved: suspend (String, String, String, Boolean) -> Unit,
) {
    val context = LocalContext.current
    val coroutineScope = rememberCoroutineScope()
    var uiState by remember { mutableStateOf<HomeWidgetConfigureUiState>(HomeWidgetConfigureUiState.Loading) }
    var selectedTab by remember { mutableStateOf(HomeWidgetConfigureTab.Group) }
    var selectedGroupId by remember {
        mutableStateOf(HomeWidgetPrefs.getWidgetConfig(context, appWidgetId)?.groupId)
    }
    var showGroupName by remember {
        mutableStateOf(HomeWidgetPrefs.getShowGroupName(context, appWidgetId))
    }
    var isSaving by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        val groups = withContext(Dispatchers.IO) { AppFunctionStorageReader.getActiveGroups(context) }
        uiState = HomeWidgetConfigureUiState.Loaded(groups)
    }

    val selectedGroup = (uiState as? HomeWidgetConfigureUiState.Loaded)
        ?.groups
        ?.firstOrNull { it.id == selectedGroupId }

    Column(
        modifier = modifier
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
                                    Row(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .then(
                                                if (isSelected) {
                                                    Modifier.background(
                                                        MaterialTheme.colorScheme.primaryContainer,
                                                        RoundedCornerShape(12.dp),
                                                    )
                                                } else {
                                                    Modifier
                                                },
                                            )
                                            .semantics {
                                                role = Role.Button
                                                contentDescription = context.getString(
                                                    R.string.widget_config_select_group_a11y,
                                                    group.title,
                                                    group.currency,
                                                )
                                            }
                                            .clickable { selectedGroupId = group.id }
                                            .padding(vertical = 12.dp, horizontal = 12.dp),
                                        verticalAlignment = Alignment.CenterVertically,
                                    ) {
                                        Column(modifier = Modifier.weight(1f)) {
                                            Text(
                                                text = group.title,
                                                style = MaterialTheme.typography.bodyLarge,
                                                color = if (isSelected) {
                                                    MaterialTheme.colorScheme.onPrimaryContainer
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
                                        }
                                        if (isSelected) {
                                            Icon(
                                                imageVector = Icons.Filled.Check,
                                                contentDescription = null,
                                                tint = MaterialTheme.colorScheme.primary,
                                                modifier = Modifier.size(24.dp),
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
                        label = context.getString(R.string.widget_config_show_group_name),
                        checked = showGroupName,
                        onCheckedChange = { showGroupName = it },
                    )
                }
            }
        }

        val saveButtonDescription = if (selectedGroup == null) {
            context.getString(R.string.widget_config_save_disabled)
        } else {
            context.getString(R.string.widget_config_save)
        }

        // Previously this reason was only exposed via contentDescription
        // (screen readers only); sighted users saw a greyed-out button with
        // no visible explanation, especially confusing when landing on the
        // Options tab before ever picking a group.
        if (selectedGroup == null) {
            Text(
                text = context.getString(R.string.widget_config_save_disabled),
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.error,
            )
        }

        Button(
            onClick = {
                selectedGroup?.let { group ->
                    isSaving = true
                    coroutineScope.launch {
                        onConfigSaved(
                            group.id,
                            group.title,
                            group.currency,
                            showGroupName,
                        )
                    }
                }
            },
            enabled = selectedGroup != null && !isSaving,
            modifier = Modifier
                .fillMaxWidth()
                .semantics {
                    contentDescription = saveButtonDescription
                },
        ) {
            Text(text = context.getString(R.string.widget_config_save))
        }
    }
}

@Composable
private fun WidgetConfigToggleRow(
    label: String,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit,
) {
    // Modifier.toggleable() (rather than a plain .clickable() on the Row plus
    // the Checkbox's own onCheckedChange) merges the label into one
    // accessible "label, checkbox, checked/unchecked" node instead of two
    // disconnected ones, and gives TalkBack the correct checkbox role.
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .toggleable(
                value = checked,
                onValueChange = onCheckedChange,
                role = Role.Checkbox,
            )
            .padding(vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Checkbox(
            checked = checked,
            onCheckedChange = null,
        )
        Text(
            text = label,
            modifier = Modifier.padding(start = 8.dp),
            style = MaterialTheme.typography.bodyMedium,
        )
    }
}
