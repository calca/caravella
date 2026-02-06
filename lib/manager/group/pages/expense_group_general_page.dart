import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:io_caravella_egm/manager/group/widgets/section_flat.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/services/notification_service.dart';
import 'package:io_caravella_egm/services/notification_manager.dart';
import '../group_form_controller.dart';
import '../group_edit_mode.dart';
import '../widgets/group_name_with_icon_field.dart';
import '../widgets/selection_tile.dart';
import '../widgets/period_section_editor.dart';
import '../widgets/currency_selector_sheet.dart';

class ExpenseGroupGeneralPage extends StatelessWidget {
  final ExpenseGroup? trip;
  final VoidCallback? onTripDeleted;
  final GroupEditMode mode;

  const ExpenseGroupGeneralPage({
    super.key,
    this.trip,
    this.onTripDeleted,
    required this.mode,
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
      ),
    );
  }
}

class _GeneralPageScaffold extends StatefulWidget {
  final ExpenseGroup? trip;
  final VoidCallback? onTripDeleted;
  final GroupEditMode mode;

  const _GeneralPageScaffold({
    required this.trip,
    this.onTripDeleted,
    required this.mode,
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
      });
    }
  }

  Future<DateTime?> _pickDate(BuildContext context, bool isStart) async {
    final gloc = gen.AppLocalizations.of(context);
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 5);
    final lastDate = DateTime(now.year + 5);
    DateTime? initialDate = isStart
        ? (_state.startDate ?? now)
        : (_state.endDate ?? now);
    bool isSelectable(DateTime d) {
      if (isStart && _state.endDate != null) {
        return !d.isAfter(_state.endDate!);
      }
      if (!isStart && _state.startDate != null) {
        return !d.isBefore(_state.startDate!);
      }
      return true;
    }

    if (!isSelectable(initialDate)) {
      DateTime candidate = isStart ? lastDate : firstDate;
      while (!isSelectable(candidate)) {
        candidate = isStart
            ? candidate.subtract(const Duration(days: 1))
            : candidate.add(const Duration(days: 1));
        if (candidate.isBefore(firstDate) || candidate.isAfter(lastDate)) {
          candidate = now;
          break;
        }
      }
      initialDate = candidate;
    }

    final picked = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: initialDate,
      selectableDayPredicate: isSelectable,
      helpText: isStart ? gloc.start_date : gloc.end_date,
    );

    if (picked != null) {
      if (isStart) {
        _state.setStartDate(picked);
      } else {
        _state.setEndDate(picked);
      }
      _validateDates();
    }
    return picked;
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
    final gloc = gen.AppLocalizations.of(context);
    final controller = context.read<GroupFormController>();
    final currentType = context.read<GroupFormState>().groupType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => GroupBottomSheetScaffold(
        title: gloc.group_type,
        scrollable: false,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...ExpenseGroupType.values.map((type) {
              final isSelected = currentType == type;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SelectionTile(
                  leading: Icon(
                    type.icon,
                    size: 24,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  title: _getGroupTypeName(gloc, type),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    controller.setGroupType(
                      isSelected ? null : type,
                      autoPopulateCategories: !isSelected,
                      defaultCategoryNames: !isSelected
                          ? _getLocalizedCategories(gloc, type)
                          : null,
                      previousTypeCategoryNames: currentType != null
                          ? _getLocalizedCategories(gloc, currentType)
                          : null,
                    );
                    Navigator.of(context).pop();
                  },
                  borderRadius: 8,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getGroupTypeName(gen.AppLocalizations gloc, ExpenseGroupType type) {
    switch (type) {
      case ExpenseGroupType.travel:
        return gloc.group_type_travel;
      case ExpenseGroupType.personal:
        return gloc.group_type_personal;
      case ExpenseGroupType.family:
        return gloc.group_type_family;
      case ExpenseGroupType.other:
        return gloc.group_type_other;
    }
  }

  List<String> _getLocalizedCategories(
    gen.AppLocalizations gloc,
    ExpenseGroupType type,
  ) {
    switch (type) {
      case ExpenseGroupType.travel:
        return [
          gloc.category_travel_transport,
          gloc.category_travel_accommodation,
          gloc.category_travel_restaurants,
        ];
      case ExpenseGroupType.personal:
        return [
          gloc.category_personal_shopping,
          gloc.category_personal_health,
          gloc.category_personal_entertainment,
        ];
      case ExpenseGroupType.family:
        return [
          gloc.category_family_groceries,
          gloc.category_family_home,
          gloc.category_family_bills,
        ];
      case ExpenseGroupType.other:
        return [
          gloc.category_other_misc,
          gloc.category_other_utilities,
          gloc.category_other_services,
        ];
    }
  }

  Widget _buildGeneralContent(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome gruppo con icona categoria
          SectionFlat(
            title: '',
            children: [
              Selector<GroupFormState, bool>(
                selector: (context, s) => s.title.trim().isEmpty,
                builder: (context, isEmpty, child) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: gloc.group_name,
                      requiredMark: true,
                      showRequiredHint: isEmpty,
                      padding: EdgeInsets.zero,
                      spacing: 4,
                    ),
                    const SizedBox(height: 12),
                    GroupNameWithIconField(
                      onIconTap: () => _showGroupTypeSelector(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Periodo
          PeriodSectionEditor(
            onPickDate: (isStart) async => _pickDate(context, isStart),
            onClearDates: _clearDates,
            errorText: _dateError,
          ),
          const SizedBox(height: 24),
          // Valuta
          SectionFlat(
            title: '',
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: gloc.currency,
                    description: gloc.currency_description,
                    padding: EdgeInsets.zero,
                    spacing: 4,
                  ),
                  const SizedBox(height: 8),
                  Selector<GroupFormState, Map<String, String>>(
                    selector: (context, s) => s.currency,
                    builder: (context, cur, child) => SelectionTile(
                      leading: Text(
                        cur['symbol'] ?? '',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(fontSize: 28),
                        semanticsLabel: '${cur['symbol']} ${cur['code']}',
                      ),
                      title: cur['name']!,
                      subtitle: '${cur['code']}',
                      trailing: Icon(
                        Icons.chevron_right,
                        size: 24,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      onTap: () async {
                        final selected =
                            await showModalBottomSheet<Map<String, String>>(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (_) => const CurrencySelectorSheet(),
                            );
                        if (selected != null && context.mounted) {
                          context.read<GroupFormState>().setCurrency(selected);
                        }
                      },
                      borderRadius: 8,
                      padding: const EdgeInsets.only(
                        left: 8,
                        top: 8,
                        bottom: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    return GestureDetector(
      onTap: _unfocusAll,
      behavior: HitTestBehavior.translucent,
      child: Selector<GroupFormState, int>(
        selector: (_, state) {
          return Object.hash(
            state.title,
            state.startDate,
            state.endDate,
            state.currency['code'],
            state.groupType,
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
                  } catch (_) {}

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
            child: Scaffold(
              appBar: CaravellaAppBar(
                title: Text(gloc.segment_general),
                actions: const [],
              ),
              body: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: DefaultTextStyle.merge(
                    style: Theme.of(context).textTheme.bodyMedium,
                    child: _buildGeneralContent(context),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
