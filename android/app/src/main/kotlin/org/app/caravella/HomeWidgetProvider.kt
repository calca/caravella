package io.caravella.egm

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
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
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import es.antonborri.home_widget.actionStartActivity as homeWidgetActionStartActivity
import io.caravella.egm.appfunctions.AppFunctionStorageReader
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class HomeWidgetProvider : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = CaravellaHomeWidget

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        updateAllWidgets(context)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        // super.onReceive() already routes ACTION_APPWIDGET_UPDATE into
        // onUpdate()/provideGlance() for the delivered widget ids; only these
        // custom broadcasts (not handled by AppWidgetProvider itself) need an
        // explicit refresh here.
        when (intent.action) {
            Intent.ACTION_DATE_CHANGED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
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

        // Awaited variant for callers that must not proceed (e.g. finish() an
        // Activity) until the widget has actually been refreshed — the
        // fire-and-forget updateAllWidgets() above can otherwise race against
        // process teardown when there's no OS-guaranteed refresh to fall back on.
        suspend fun updateAllWidgetsAndAwait(context: Context) {
            withContext(Dispatchers.IO) {
                CaravellaHomeWidget.updateAll(context.applicationContext)
            }
        }
    }
}

private object CaravellaHomeWidget : GlanceAppWidget() {
    // Responsive breakpoints for the two supported home-screen grid shapes —
    // square only. Values are Android's own per-cell-count guidance:
    // https://developer.android.com/develop/ui/views/appwidgets/layouts
    private val SIZE_1X1 = DpSize(57.dp, 51.dp)
    private val SIZE_2X2 = DpSize(130.dp, 117.dp)

    override val sizeMode = SizeMode.Responsive(
        setOf(SIZE_1X1, SIZE_2X2),
    )

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val appWidgetId = GlanceAppWidgetManager(context).getAppWidgetId(id)
        val config = HomeWidgetPrefs.getWidgetConfig(context, appWidgetId)

        val model = if (config == null) {
            // Tapping anywhere on the unconfigured widget opens the group picker,
            // not just the small CTA chip — matches the configured widget's
            // full-body tap and avoids a dead area that looks unresponsive.
            val configureAction = glanceActionStartActivity(
                Intent(context, HomeWidgetConfigureActivity::class.java).apply {
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                },
            )
            WidgetUiModel(
                title = context.getString(R.string.widget_unconfigured_title),
                todayValue = "-",
                weekValue = "-",
                ctaButton = WidgetButton(
                    label = context.getString(R.string.widget_select_group),
                    action = configureAction,
                ),
                tapAction = configureAction,
            )
        } else {
            val totals = AppFunctionStorageReader.getWidgetTotals(context, config.groupId)
            val title = totals?.groupTitle ?: config.groupTitle
            val currency = totals?.currency ?: config.groupCurrency
            // Both actions go through the home_widget plugin's own launch-intent
            // mechanism (a caravella://home_widget/... deep link delivered via
            // HomeWidget.initiallyLaunchedFromHomeWidget()/widgetClicked on the Dart
            // side) so the CTA button genuinely opens the add-expense sheet, distinct
            // from tapping the rest of the widget which just opens the group.
            val addExpenseAction = homeWidgetActionStartActivity<MainActivity>(
                context,
                widgetTapUri("add_expense", config.groupId, title),
            )
            val openGroupAction = homeWidgetActionStartActivity<MainActivity>(
                context,
                widgetTapUri("open_group", config.groupId, title),
            )
            WidgetUiModel(
                title = title,
                // Default to 0.0 when totals are unavailable (e.g. first load before
                // any expenses exist) so the widget always shows a formatted amount
                // instead of a placeholder dash.
                todayValue = formatWidgetAmount(totals?.todayTotal ?: 0.0, currency),
                weekValue = formatWidgetAmount(totals?.weekTotal ?: 0.0, currency),
                ctaButton = WidgetButton(
                    label = "+",
                    action = addExpenseAction,
                ),
                tapAction = openGroupAction,
            )
        }

        val accentColors = widgetAccentColors(context)

        provideContent {
            val size = LocalSize.current
            // Midpoint between the two declared breakpoints (57dp vs 130dp wide) —
            // LocalSize.current always snaps to one of the two exactly, so any
            // threshold strictly between them classifies correctly.
            val isOneByOne = size.width < 100.dp

            // The tap target and the painted surface are deliberately two nested
            // Boxes rather than one: background() on the true root element
            // returned from provideContent() has been unreliable in practice
            // (renders transparent on some API levels/launchers even with a
            // fully opaque color), so the actual painted surface lives on an
            // inner Box one level down, while the outer one only carries
            // sizing and the click target.
            val outerModifier = if (model.tapAction != null) {
                GlanceModifier.fillMaxSize().clickable(model.tapAction)
            } else {
                GlanceModifier.fillMaxSize()
            }

            Box(modifier = outerModifier) {
                Box(
                    modifier = GlanceModifier
                        .fillMaxSize()
                        .cornerRadius(WidgetOuterRadius)
                        .background(WidgetSurfaceColor),
                ) {
                    if (isOneByOne) {
                        OneByOneContent(model)
                    } else {
                        TwoByTwoContent(context, model, accentColors)
                    }
                }
            }
        }
    }

    @Composable
    private fun OneByOneContent(model: WidgetUiModel) {
        // Smallest grid cell: group name + today's value, both sized down from
        // the 2x2 layout's since this cell is much narrower/shorter.
        val overlayModifier = GlanceModifier.fillMaxSize().padding(WidgetCompactPadding)
        Box(modifier = overlayModifier, contentAlignment = Alignment.Center) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = model.title,
                    style = TextStyle(
                        color = EmphasisTextColor,
                        fontWeight = FontWeight.Bold,
                        fontSize = WidgetMicroLabelTextSize,
                    ),
                    maxLines = 1,
                )
                Text(
                    text = model.todayValue,
                    style = TextStyle(
                        color = EmphasisTextColor,
                        fontSize = WidgetMicroValueTextSize,
                        fontWeight = FontWeight.Bold,
                    ),
                    maxLines = 1,
                )
            }
        }
    }

    @Composable
    private fun TwoByTwoContent(
        context: Context,
        model: WidgetUiModel,
        accentColors: WidgetAccentColors,
    ) {
        // Same "only show when genuinely different from the whole-cell tap" rule as
        // the 4x1 chip: in the unconfigured state the CTA and the tap-anywhere action
        // are identical, so a redundant floating button would just add visual noise.
        val showsDistinctCta = model.ctaButton != null && model.ctaButton.action != model.tapAction
        Box(modifier = GlanceModifier.fillMaxSize()) {
            // Two zones stacked in a Column: the group name pinned top-start (its own
            // row, natural height), then a second row that fills whatever vertical
            // space is left and centers today's value + the week chip inside it —
            // so the header stays put while the hero number gets the visual weight
            // of true centering, rather than the whole block sitting off-center.
            Column(modifier = GlanceModifier.fillMaxSize().padding(WidgetCellPadding)) {
                Text(
                    text = model.title,
                    style = TextStyle(
                        color = EmphasisTextColor,
                        fontWeight = FontWeight.Bold,
                        fontSize = WidgetLabelTextSize,
                    ),
                    maxLines = 1,
                )
                Box(
                    // Bottom padding equal to the CTA button's own footprint: the
                    // button is a sibling overlay, not part of this Column's layout,
                    // so without this the centered content below would center against
                    // the cell's true bottom edge instead of the button's top edge.
                    modifier = GlanceModifier.fillMaxWidth().defaultWeight()
                        .padding(bottom = WidgetCtaButtonSize),
                    contentAlignment = Alignment.Center,
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = model.todayValue,
                            style = TextStyle(
                                color = EmphasisTextColor,
                                fontSize = WidgetCompactValueTextSize,
                                fontWeight = FontWeight.Bold,
                            ),
                            maxLines = 1,
                        )
                        Box(
                            modifier = GlanceModifier
                                .padding(top = WidgetMinimalSpacing)
                                .cornerRadius(WidgetWeekPillRadius)
                                .background(accentColors.weekPillSurface)
                                .padding(
                                    start = WidgetWeekPillHorizontalPadding,
                                    end = WidgetWeekPillHorizontalPadding,
                                    top = WidgetWeekPillTopPadding,
                                    bottom = WidgetWeekPillBottomPadding,
                                ),
                            contentAlignment = Alignment.Center,
                        ) {
                            Text(
                                text = "${context.getString(R.string.widget_week_label)} ${model.weekValue}",
                                style = TextStyle(
                                    color = accentColors.weekPillText,
                                    fontSize = WidgetWeekPillTextSize,
                                    fontWeight = FontWeight.Bold,
                                ),
                                maxLines = 1,
                            )
                        }
                    }
                }
            }
            if (showsDistinctCta) {
                val ctaButton = model.ctaButton!!
                Box(
                    modifier = GlanceModifier.fillMaxSize().padding(WidgetCellPadding),
                    contentAlignment = Alignment.BottomEnd,
                ) {
                    Box(
                        modifier = GlanceModifier
                            .size(WidgetCtaButtonSize)
                            .cornerRadius(WidgetCtaButtonRadius)
                            .background(accentColors.ctaSurface)
                            .clickable(ctaButton.action),
                        contentAlignment = Alignment.Center,
                    ) {
                        Text(
                            text = ctaButton.label,
                            style = TextStyle(
                                color = accentColors.ctaText,
                                fontSize = WidgetCtaButtonTextSize,
                                fontWeight = FontWeight.Bold,
                            ),
                        )
                    }
                }
            }
        }
    }

    private fun widgetTapUri(path: String, groupId: String, groupTitle: String): Uri =
        Uri.Builder()
            .scheme("caravella")
            .authority("home_widget")
            .appendPath(path)
            .appendQueryParameter("groupId", groupId)
            .appendQueryParameter("groupTitle", groupTitle)
            .build()
}

private data class WidgetUiModel(
    val title: String,
    val todayValue: String,
    val weekValue: String,
    val ctaButton: WidgetButton?,
    val tapAction: Action?,
)

// Label + action pair used by widget primary/secondary buttons.
private data class WidgetButton(
    val label: String,
    val action: Action,
)
