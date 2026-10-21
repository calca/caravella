import '../../details/pages/tabs/usecase/date_range_formatter.dart';
import '../widgets/period_selection_bottom_sheet.dart';
import '../widgets/group_title_field.dart';
import '../group_type/group_type_localization.dart';
import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import 'package:io_caravella_egm/services/notification_manager.dart';
import '../group_form_controller.dart';
import '../group_edit_mode.dart';
import '../group_type/group_type_selector_sheet.dart';
import '../widgets/background_picker.dart';
import '../widgets/currency_selector_sheet.dart';

class ExpenseGroupGeneralPage extends StatelessWidget {
  final ExpenseGroup? trip;
  final VoidCallback? onTripDeleted;
  final GroupEditMode mode;

  /// Opens the background sheet right away (the settings avatar shortcut).
  final bool openBackground;

  const ExpenseGroupGeneralPage({
    super.key,
    this.trip,
    this.onTripDeleted,
    required this.mode,
    this.openBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GroupFormState()),
        ProxyProvider2<
          GroupFormState,
          ExpenseGroupNotifier,
          GroupFormController
        >(
          update: (context, state, notifier, previous) => GroupFormController(
            state,
            mode,
            notifier,
            () {
              final gloc = gen.AppLocalizations.of(context);
              AppToast.show(
                context,
                gloc.group_added_success,
                type: ToastType.success,
              );
            },
            (error) {
              final gloc = gen.AppLocalizations.of(context);
              AppToast.show(
                context,
                gloc.error_saving_group(error.toString()),
                type: ToastType.error,
              );
            },
          ),
        ),
      ],
      child: _GeneralPageScaffold(
        trip: trip,
        onTripDeleted: onTripDeleted,
        mode: mode,
        openBackground: openBackground,
      ),
    );
  }
}

class _GeneralPageScaffold extends StatefulWidget {
  final ExpenseGroup? trip;
  final VoidCallback? onTripDeleted;
  final GroupEditMode mode;
  final bool openBackground;

  const _GeneralPageScaffold({
    required this.trip,
    this.onTripDeleted,
    required this.mode,
    this.openBackground = false,
  });

  @override
  State<_GeneralPageScaffold> createState() => _GeneralPageScaffoldState();
}

class _GeneralPageScaffoldState extends State<_GeneralPageScaffold> {
  String? _dateError;
  final _formKey = GlobalKey<FormState>();

  GroupFormState get _state => context.read<GroupFormState>();
  GroupFormController get _controller => context.read<GroupFormController>();

  @override
  void initState() {
    super.initState();

    if (widget.trip != null && widget.mode == GroupEditMode.edit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _state.title.isEmpty) {
          _controller.load(widget.trip!);
        }
        if (mounted && widget.openBackground) {
          showBackgroundPickerSheet(context);
        }
      });
    }
  }

  void _clearDates() {
    _state.clearDates();
    _validateDates();
  }

  void _validateDates() {
    final gloc = gen.AppLocalizations.of(context);
    setState(() {
      _dateError = null;
    });
    if ((_state.startDate != null && _state.endDate == null) ||
        (_state.startDate == null && _state.endDate != null)) {
      _dateError = gloc.select_both_dates;
    }
    if (_state.startDate != null &&
        _state.endDate != null &&
        _state.endDate!.isBefore(_state.startDate!)) {
      _dateError = gloc.end_date_after_start;
    }
  }

  void _unfocusAll() {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.unfocus();
    }
  }

  void _showGroupTypeSelector(BuildContext context) {
    showGroupTypeSelectorSheet(context);
  }

  Widget _buildGeneralContent(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final state = context.watch<GroupFormState>();
    final type = state.groupType;
    final hasDates = state.startDate != null || state.endDate != null;
    final days = state.startDate != null && state.endDate != null
        ? state.endDate!.difference(state.startDate!).inDays + 1
        : null;
    final currency = state.currency;
    final background = state.imagePath != null
        ? gloc.background_photo
        : state.color != null
        ? gloc.color
        : gloc.background_none;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Name: a big field in its own card, like the creation wizard.
        SettingsGroup(
          label: gloc.group_name,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: GroupTitleField(
                hintText: gloc.enter_title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: gloc.enter_title,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorText: state.title.trim().isEmpty
                      ? gloc.enter_title
                      : null,
                ),
              ),
            ),
          ],
        ),
        SettingsGroup(
          children: [
            SettingsTile(
              icon:
                  type?.icon ??
                  (state.customTemplateIconCodePoint != null
                      ? GroupTypeLocalization.iconFromCodePoint(
                          state.customTemplateIconCodePoint!,
                        )
                      : Icons.category_outlined),
              title: gloc.group_type,
              subtitle: type != null
                  ? GroupTypeLocalization.typeName(gloc, type)
                  : null,
              onTap: () => _showGroupTypeSelector(context),
            ),
            SettingsTile(
              icon: Icons.event_outlined,
              title: gloc.period,
              subtitle: hasDates
                  ? [
                      formatDateRange(
                        start: state.startDate,
                        end: state.endDate,
                        locale: Localizations.localeOf(context),
                      ),
                      ?(days != null ? gloc.days_count(days) : null),
                    ].join(' · ')
                  : gloc.dates_description,
              subtitleWidget: _dateError != null
                  ? Text(_dateError!, style: TextStyle(color: s.error))
                  : null,
              trailing: hasDates
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: gloc.clear_dates,
                      onPressed: _clearDates,
                    )
                  : null,
              onTap: () => showPeriodSelectionBottomSheet(
                context: context,
                initialStartDate: state.startDate,
                initialEndDate: state.endDate,
                onSelectionChanged: (start, end) {
                  state.setDates(start: start, end: end);
                  _validateDates();
                },
              ),
            ),
            SettingsTile(
              icon: Icons.payments_outlined,
              title: gloc.currency,
              subtitle:
                  '${currency['symbol'] ?? ''}  ${currency['name'] ?? ''} · '
                  '${currency['code'] ?? ''}',
              onTap: () async {
                final selected =
                    await showModalBottomSheet<Map<String, String>>(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (_) =>
                          CurrencySelectorSheet(selectedCode: currency['code']),
                    );
                if (selected != null && context.mounted) {
                  context.read<GroupFormState>().setCurrency(selected);
                }
              },
            ),
            SettingsTile(
              icon: Icons.image_outlined,
              title: gloc.background,
              subtitle: background,
              trailing: _BackgroundPreview(state: state),
              onTap: () => showBackgroundPickerSheet(context),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocusAll,
      behavior: HitTestBehavior.translucent,
      // Tap-outside-to-dismiss-keyboard only; not an action for screen readers.
      excludeFromSemantics: true,
      child: Selector<GroupFormState, int>(
        selector: (_, state) {
          return Object.hash(
            state.title,
            state.startDate,
            state.endDate,
            state.currency['code'],
            state.groupType,
            state.imagePath,
            state.color,
          );
        },
        builder: (context, _, _) {
          final controller = context.read<GroupFormController>();
          return PopScope(
            canPop: !controller.hasChanges,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              if (controller.hasChanges) {
                final navigator = Navigator.of(context);
                ExpenseGroupNotifier? notifier;
                try {
                  notifier = context.read<ExpenseGroupNotifier>();
                } catch (_) {
                  notifier = null;
                }
                final gloc = gen.AppLocalizations.of(context);

                try {
                  final saved = await controller.save();

                  ExpenseGroupStorageV2.forceReload();
                  try {
                    notifier?.notifyGroupUpdated(saved.id);
                  } catch (e) {
                    LoggerService.warning(
                      'Failed to notify group updated after save: $e',
                      name: 'manager.group',
                    );
                  }

                  if (saved.notificationEnabled && context.mounted) {
                    await NotificationManager().updateNotificationForGroup(
                      saved,
                      gloc,
                    );
                  } else {
                    await NotificationManager().cancelNotificationForGroup(
                      saved.id,
                    );
                  }

                  if (navigator.canPop()) navigator.pop(true);
                } catch (e, st) {
                  LoggerService.error(
                    'Failed to save group on back navigation',
                    name: 'manager.group',
                    error: e,
                    stackTrace: st,
                  );

                  if (context.mounted) {
                    AppToast.show(
                      context,
                      gloc.error_saving_group(e.toString()),
                      type: ToastType.error,
                    );
                  }
                }
                return;
              }

              if (context.mounted) {
                final navigator = Navigator.of(context);
                if (navigator.canPop()) navigator.pop();
              }
            },
            child: AppSystemUI.edgeToEdge(
              child: SettingsScaffold(
                eyebrow: gen.AppLocalizations.of(context).group,
                title: gen.AppLocalizations.of(context).segment_general,
                children: [
                  Form(
                    key: _formKey,
                    child: DefaultTextStyle.merge(
                      style: Theme.of(context).textTheme.bodyMedium,
                      child: _buildGeneralContent(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Small preview of the group's background at the end of its row: the photo,
/// the color, or nothing.
class _BackgroundPreview extends StatelessWidget {
  final GroupFormState state;

  const _BackgroundPreview({required this.state});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final path = state.imagePath;
    final color = state.color;
    Widget? child;
    if (path != null) {
      child = Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
    } else if (color != null) {
      final resolved = ExpenseGroupColorPalette.isLegacyColorValue(color)
          ? Color(color)
          : ExpenseGroupColorPalette.resolveColor(color, s);
      if (resolved != null) child = ColoredBox(color: resolved);
    }
    if (child == null) {
      return Icon(Icons.chevron_right_rounded, color: s.onSurfaceVariant);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(width: 40, height: 40, child: child),
    );
  }
}
