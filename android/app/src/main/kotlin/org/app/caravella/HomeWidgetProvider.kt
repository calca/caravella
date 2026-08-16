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
import androidx.glance.layout.Row
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
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
    // Responsive breakpoints for the four supported home-screen grid shapes.
    // Values are Android's own per-cell-count guidance (portrait width column,
    // landscape height column — the smaller, safer figure for each dimension):
    // https://developer.android.com/develop/ui/views/appwidgets/layouts
    private val SIZE_1X1 = DpSize(57.dp, 51.dp)
    private val SIZE_2X2 = DpSize(130.dp, 117.dp)
    private val SIZE_4X1 = DpSize(276.dp, 51.dp)
    private val SIZE_4X2 = DpSize(276.dp, 117.dp)

    override val sizeMode = SizeMode.Responsive(
        setOf(SIZE_1X1, SIZE_2X2, SIZE_4X1, SIZE_4X2),
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
                groupTotalValue = "-",
                showGroupName = true,
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
                groupTotalValue = formatWidgetAmount(totals?.groupTotal ?: 0.0, currency),
                showGroupName = config.showGroupName,
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
            // Midpoints between the declared breakpoints (130/276 wide, 51/117 tall) —
            // LocalSize.current always snaps to one of the four exactly, so any
            // threshold strictly between two breakpoint values classifies correctly.
            val isNarrow = size.width < 200.dp // 1x1 or 2x2 width
            val isShort = size.height < 84.dp // 1x1 or 4x1 height

            val baseModifier = GlanceModifier
                .fillMaxSize()
                .cornerRadius(WidgetOuterRadius)
                .background(WidgetSurfaceColor)
            val clickableContainerModifier = if (model.tapAction != null) {
                baseModifier.clickable(model.tapAction)
            } else {
                baseModifier
            }

            Box(modifier = clickableContainerModifier) {
                when {
                    isNarrow && isShort -> OneByOneContent(model)
                    isNarrow && !isShort -> TwoByTwoContent(context, model)
                    !isNarrow && isShort -> FourByOneContent(context, model, accentColors)
                    else -> FourByTwoContent(context, model, accentColors)
                }
            }
        }
    }

    @Composable
    private fun OneByOneContent(model: WidgetUiModel) {
        // Smallest grid cell: group name (when enabled) + today's value, both
        // sized down from the 2x2 layout's since this cell is much narrower/shorter.
        val overlayModifier = GlanceModifier.fillMaxSize().padding(WidgetCompactPadding)
        Box(modifier = overlayModifier, contentAlignment = Alignment.Center) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                if (model.showGroupName) {
                    Text(
                        text = model.title,
                        style = TextStyle(
                            color = EmphasisTextColor,
                            fontWeight = FontWeight.Bold,
                            fontSize = WidgetMicroLabelTextSize,
                        ),
                        maxLines = 1,
                    )
                }
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
    private fun TwoByTwoContent(context: Context, model: WidgetUiModel) {
        val overlayModifier = GlanceModifier.fillMaxSize().padding(WidgetCompactPadding)
        Box(modifier = overlayModifier, contentAlignment = Alignment.Center) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                if (model.showGroupName) {
                    Text(
                        text = model.title,
                        style = TextStyle(
                            color = EmphasisTextColor,
                            fontWeight = FontWeight.Bold,
                            fontSize = WidgetLabelTextSize,
                        ),
                        maxLines = 1,
                    )
                }
                Text(
                    text = model.todayValue,
                    style = TextStyle(
                        color = EmphasisTextColor,
                        fontSize = WidgetCompactValueTextSize,
                        fontWeight = FontWeight.Bold,
                    ),
                    maxLines = 1,
                )
                Text(
                    text = "${context.getString(R.string.widget_week_label)} ${model.weekValue}",
                    style = TextStyle(
                        color = SecondaryTextColor,
                        fontSize = WidgetLabelTextSize,
                    ),
                    maxLines = 1,
                )
            }
        }
    }

    @Composable
    private fun FourByOneContent(
        context: Context,
        model: WidgetUiModel,
        accentColors: WidgetAccentColors,
    ) {
        // A single short row: no vertical room to stack the group name, value and
        // CTA the way the taller layouts do, so everything lives on one line.
        // The CTA chip is only drawn when it's a genuinely different action from
        // the whole-row tap (the configured state's "+"); in the unconfigured
        // state both actions already open the same picker, so a second visual
        // button would be redundant and — with its long "select group" label —
        // wouldn't fit this row's height anyway.
        val showsDistinctCta = model.ctaButton != null && model.ctaButton.action != model.tapAction
        Box(
            modifier = GlanceModifier.fillMaxSize().padding(horizontal = WidgetInnerPadding),
        ) {
            val line = if (model.showGroupName) {
                "${model.title} · ${model.todayValue}"
            } else {
                model.todayValue
            }
            Box(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .padding(end = if (showsDistinctCta) WidgetCtaButtonSmallReservedWidth else 0.dp),
                contentAlignment = Alignment.CenterStart,
            ) {
                Text(
                    text = line,
                    style = TextStyle(
                        color = EmphasisTextColor,
                        fontSize = WidgetBodyTextSize,
                        fontWeight = FontWeight.Bold,
                    ),
                    maxLines = 1,
                )
            }
            if (showsDistinctCta) {
                val ctaButton = model.ctaButton!!
                Box(
                    modifier = GlanceModifier.fillMaxSize(),
                    contentAlignment = Alignment.CenterEnd,
                ) {
                    Box(
                        modifier = GlanceModifier
                            .cornerRadius(WidgetCtaButtonSmallRadius)
                            .background(accentColors.ctaSurface)
                            .padding(WidgetCtaButtonSmallPadding)
                            .clickable(ctaButton.action),
                        contentAlignment = Alignment.Center,
                    ) {
                        Text(
                            text = ctaButton.label,
                            style = TextStyle(
                                color = accentColors.ctaText,
                                fontSize = WidgetCtaButtonSmallTextSize,
                                fontWeight = FontWeight.Bold,
                            ),
                        )
                    }
                }
            }
        }
    }

    @Composable
    private fun FourByTwoContent(
        context: Context,
        model: WidgetUiModel,
        accentColors: WidgetAccentColors,
    ) {
        val overlayModifier = GlanceModifier
            .fillMaxSize()
            .padding(WidgetInnerPadding)

        Box(modifier = overlayModifier) {
            Column(
                modifier = GlanceModifier.fillMaxSize(),
            ) {
                // First row: "Total Spent" label + "today: $total" chip
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                ) {
                    Text(
                        text = context.getString(R.string.widget_total_spent_label),
                        style = TextStyle(
                            color = EmphasisTextColor,
                            fontWeight = FontWeight.Bold,
                            fontSize = WidgetBodyTextSize,
                        ),
                        maxLines = 1,
                    )
                    Box(
                        modifier = GlanceModifier
                            .padding(start = 8.dp)
                            .cornerRadius(WidgetTodayPillRadius)
                            .background(accentColors.pillSurface)
                            .padding(
                                start = WidgetTodayPillHorizontalPadding,
                                top = WidgetTodayPillVerticalPadding,
                                end = WidgetTodayPillHorizontalPadding,
                                bottom = WidgetTodayPillVerticalPadding,
                            ),
                    ) {
                        Text(
                            text = "${context.getString(R.string.widget_today_label)} ${model.todayValue}",
                            style = TextStyle(
                                color = accentColors.pillText,
                                fontSize = WidgetLabelTextSize,
                                fontWeight = FontWeight.Bold,
                            ),
                        )
                    }
                }

                if (model.showGroupName) {
                    Text(
                        text = model.title,
                        style = TextStyle(
                            color = SecondaryTextColor,
                            fontSize = WidgetLabelTextSize,
                        ),
                        maxLines = 1,
                        modifier = GlanceModifier.padding(top = WidgetMinimalSpacing),
                    )
                }

                Text(
                    text = model.groupTotalValue,
                    style = TextStyle(
                        color = EmphasisTextColor,
                        fontSize = WidgetGroupTotalValueTextSize,
                        fontWeight = FontWeight.Bold,
                    ),
                    modifier = GlanceModifier.padding(top = WidgetSectionSpacing),
                )
            }

            // CTA + button: always bottom-right, square with rounded corners
            if (model.ctaButton != null) {
                Box(
                    modifier = GlanceModifier.fillMaxSize(),
                    contentAlignment = Alignment.BottomEnd,
                ) {
                    Box(
                        modifier = GlanceModifier
                            .cornerRadius(WidgetCtaButtonRadius)
                            .background(accentColors.ctaSurface)
                            .padding(WidgetCtaButtonPadding)
                            .clickable(model.ctaButton.action),
                        contentAlignment = Alignment.Center,
                    ) {
                        Text(
                            text = model.ctaButton.label,
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
    val groupTotalValue: String,
    val showGroupName: Boolean,
    val ctaButton: WidgetButton?,
    val tapAction: Action?,
)

// Label + action pair used by widget primary/secondary buttons.
private data class WidgetButton(
    val label: String,
    val action: Action,
)
