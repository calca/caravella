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
import '../widgets/group_title_field.dart';
import '../widgets/participants_editor.dart';
import '../widgets/categories_editor.dart';
import '../widgets/selection_tile.dart';
import '../widgets/period_section_editor.dart';
import '../widgets/currency_selector_sheet.dart';
import '../widgets/background_picker.dart';

class ExpensesGroupEditPage extends StatelessWidget {
  final ExpenseGroup? trip;
  final VoidCallback? onTripDeleted;

  /// Specifica se la pagina opera in modalità creazione o modifica.
  /// Se non fornito, viene dedotto automaticamente: trip == null => create, altrimenti edit.
  final GroupEditMode mode;

  const ExpensesGroupEditPage({
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
              AppToast.show(context, gloc.backup_error, type: ToastType.error);
            },
          ),
        ),
      ],
      child: _GroupFormScaffold(
        trip: trip,
        onTripDeleted: onTripDeleted,
        mode: mode,
      ),
    );
  }
}

class _GroupFormScaffold extends StatefulWidget {
  final ExpenseGroup? trip;
  final VoidCallback? onTripDeleted;
  final GroupEditMode mode;
  const _GroupFormScaffold({
    required this.trip,
    this.onTripDeleted,
    required this.mode,
  });
  @override
  State<_GroupFormScaffold> createState() => _GroupFormScaffoldState();
}

class _GroupFormScaffoldState extends State<_GroupFormScaffold>
    with TickerProviderStateMixin {
  String? _dateError;
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  GroupFormState get _state => context.read<GroupFormState>();
  GroupFormController get _controller => context.read<GroupFormController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      animationDuration: const Duration(milliseconds: 350),
    );

    // Register callback to handle notification disable from notification
    NotificationManager.onNotificationDisabled = _handleNotificationDisabled;

    if (widget.trip != null && widget.mode == GroupEditMode.edit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _state.title.isEmpty) {
          _controller.load(widget.trip!);
        }
      });
    } else if (widget.mode == GroupEditMode.create) {
      // For new groups, add user as first participant if name is available
      // and add default categories for the default group type (personal)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final userNameNotifier = context.read<UserNameNotifier>();
          if (userNameNotifier.hasName) {
            _state.addParticipant(
              ExpenseParticipant(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: userNameNotifier.name,
              ),
            );
          }

          // Add default categories for personal type (default type)
          if (_state.categories.isEmpty &&
              _state.groupType == ExpenseGroupType.personal) {
            final gloc = gen.AppLocalizations.of(context);
            final defaultCategories = _getLocalizedCategories(
              gloc,
              ExpenseGroupType.personal,
            );
            for (int i = 0; i < defaultCategories.length; i++) {
              _state.addCategory(
                ExpenseCategory(
                  id: '${DateTime.now().millisecondsSinceEpoch}_$i',
                  name: defaultCategories[i],
                ),
              );
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    // Unregister callback
    NotificationManager.onNotificationDisabled = null;
    _tabController.dispose();
    super.dispose();
  }

  /// Handles notification disable events from the notification
  void _handleNotificationDisabled(String groupId) {
    // Only update if this is the group being edited
    if (widget.trip?.id == groupId && mounted) {
      _state.setNotificationEnabled(false);
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
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: isStart ? gloc.select_from_date : gloc.select_to_date,
      cancelText: gloc.cancel,
      confirmText: gloc.ok,
      locale: Locale(Localizations.localeOf(context).languageCode),
      selectableDayPredicate: isSelectable,
    );
    if (picked != null) {
      if (isStart) {
        _state.setDates(start: picked, end: _state.endDate);
      } else {
        _state.setDates(start: _state.startDate, end: picked);
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

  // Tab validation helpers
  bool _isGeneralTabValid() {
    return _state.title.trim().isNotEmpty;
  }

  bool _isParticipantsTabValid() {
    return _state.participants.isNotEmpty;
  }

  bool _isCategoriesTabValid() {
    return _state.categories.isNotEmpty;
  }

  Widget _buildTabWithValidation(
    String label,
    bool isValid,
    BuildContext context,
  ) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 4),
          Text(
            '*',
            style: TextStyle(
              color: isValid
                  ? Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6)
                  : Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTab(BuildContext context) {
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
                    Selector<GroupFormState, ExpenseGroupType?>(
                      selector: (context, s) => s.groupType,
                      builder: (context, groupType, child) => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => _showGroupTypeSelector(context),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                groupType?.icon ?? Icons.category_outlined,
                                size: 24,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(child: GroupTitleField()),
                        ],
                      ),
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

  Widget _buildParticipantsTab() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ParticipantsEditor(),
    );
  }

  Widget _buildCategoriesTab() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: CategoriesEditor(),
    );
  }

  Widget _buildOtherTab(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionFlat(
            title: '',
            children: [
              // Sfondo
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: gloc.background,
                    description: gloc.choose_image_or_color,
                    padding: EdgeInsets.zero,
                    spacing: 4,
                  ),
                  const SizedBox(height: 12),
                  const BackgroundPicker(),
                ],
              ),
              const SizedBox(height: 32),
              // Notifica persistente
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: gloc.notification_enabled,
                    description: gloc.notification_enabled,
                    padding: EdgeInsets.zero,
                    spacing: 4,
                  ),
                  const SizedBox(height: 12),
                  Selector<GroupFormState, bool>(
                    selector: (context, s) => s.notificationEnabled,
                    builder: (context, enabled, child) => Semantics(
                      toggled: enabled,
                      label:
                          '${gloc.notification_enabled} - ${enabled ? gloc.accessibility_currently_enabled : gloc.accessibility_currently_disabled}',
                      hint: gloc.notification_enabled,
                      child: SwitchListTile(
                        title: Text(gloc.notification_enabled),
                        subtitle: Text(
                          enabled
                              ? gloc.accessibility_currently_enabled
                              : gloc.accessibility_currently_disabled,
                        ),
                        value: enabled,
                        onChanged: (value) async {
                          final controller = context
                              .read<GroupFormController>();
                          final notificationService = NotificationService();

                          // If enabling, request permissions first
                          if (value) {
                            final granted = await notificationService
                                .requestPermissions();
                            if (!granted && context.mounted) {
                              AppToast.show(
                                context,
                                gloc.notification_enabled,
                                type: ToastType.info,
                              );
                              return;
                            }
                          }

                          // Update state (save happens on PopScope)
                          controller.state.setNotificationEnabled(value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Posizione automatica
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: gloc.settings_auto_location_section,
                    description: gloc.settings_auto_location_section_desc,
                    padding: EdgeInsets.zero,
                    spacing: 4,
                  ),
                  const SizedBox(height: 12),
                  Selector<GroupFormState, bool>(
                    selector: (context, s) => s.autoLocationEnabled,
                    builder: (context, enabled, child) => Semantics(
                      toggled: enabled,
                      label:
                          '${gloc.settings_auto_location_title} - ${enabled ? gloc.accessibility_currently_enabled : gloc.accessibility_currently_disabled}',
                      hint: gloc.settings_auto_location_desc,
                      child: SwitchListTile(
                        title: Text(gloc.settings_auto_location_title),
                        subtitle: Text(gloc.settings_auto_location_desc),
                        value: enabled,
                        onChanged: (value) async {
                          final controller = context
                              .read<GroupFormController>();
                          final notifier = context.read<ExpenseGroupNotifier>();
                          controller.state.setAutoLocationEnabled(value);
                          try {
                            await controller.save();
                            if (controller.state.id != null) {
                              notifier.notifyGroupUpdated(controller.state.id!);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              AppToast.show(
                                context,
                                gloc.backup_error,
                                type: ToastType.error,
                              );
                            }
                          }
                        },
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
          // Create a hash of all fields that affect hasChanges
          // This forces rebuild when any relevant field changes
          return Object.hash(
            state.title,
            state.participants.length,
            state.categories.length,
            state.startDate,
            state.endDate,
            state.imagePath,
            state.color,
            state.currency['code'],
            state.groupType,
            state.autoLocationEnabled,
          );
        },
        builder: (context, _, _) {
          final controller = context.read<GroupFormController>();
          return PopScope(
            canPop: !controller.hasChanges,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              if (controller.hasChanges) {
                // Capture context-dependent objects before awaiting
                final navigator = Navigator.of(context);
                ExpenseGroupNotifier? notifier;
                try {
                  notifier = context.read<ExpenseGroupNotifier>();
                } catch (_) {
                  notifier = null;
                }
                final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
                final gloc = gen.AppLocalizations.of(context);

                try {
                  final saved = await controller.save();

                  // Ensure repository and global listeners refresh
                  ExpenseGroupStorageV2.forceReload();
                  try {
                    notifier?.notifyGroupUpdated(saved.id);
                  } catch (_) {}

                  // Handle notification state after save
                  final notificationService = NotificationService();
                  if (saved.notificationEnabled && context.mounted) {
                    // Show or update notification
                    await notificationService.showGroupNotification(
                      saved,
                      gloc,
                    );
                  } else {
                    // Cancel notification if disabled
                    await notificationService.cancelGroupNotification(saved.id);
                  }

                  // Pop returning the saved id so caller can react
                  if (navigator.canPop()) navigator.pop(saved.id);
                } catch (e) {
                  // Show error toast using captured messenger if possible (avoids using
                  // BuildContext after async gap).
                  if (scaffoldMessenger != null && context.mounted) {
                    AppToast.show(
                      context,
                      gloc.backup_error,
                      type: ToastType.error,
                    );
                  } else if (context.mounted) {
                    AppToast.show(
                      context,
                      gloc.backup_error,
                      type: ToastType.error,
                    );
                  }
                }
                return;
              }

              // No changes -> just pop normally
              if (context.mounted) {
                final navigator = Navigator.of(context);
                if (navigator.canPop()) navigator.pop();
              }
            },
            child: Scaffold(
              appBar: CaravellaAppBar(actions: []),
              body: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            key: _formKey,
                            child: DefaultTextStyle.merge(
                              style: Theme.of(context).textTheme.bodyMedium,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SectionHeader(
                                    title: widget.mode == GroupEditMode.edit
                                        ? gloc.edit_group
                                        : gloc.new_group,
                                    description:
                                        widget.mode == GroupEditMode.edit
                                        ? gloc.edit_group_desc
                                        : gloc.new_group_desc,
                                  ),
                                  const SizedBox(height: 12),
                                  Selector<GroupFormState, int>(
                                    selector: (_, s) => Object.hash(
                                      s.title.trim().isEmpty,
                                      s.participants.isEmpty,
                                      s.categories.isEmpty,
                                    ),
                                    builder: (context, hash, child) {
                                      return CaravellaTabBar(
                                        controller: _tabController,
                                        isScrollable: true,
                                        tabAlignment: TabAlignment.start,
                                        tabs: [
                                          _buildTabWithValidation(
                                            gloc.segment_general,
                                            _isGeneralTabValid(),
                                            context,
                                          ),
                                          _buildTabWithValidation(
                                            gloc.participants,
                                            _isParticipantsTabValid(),
                                            context,
                                          ),
                                          _buildTabWithValidation(
                                            gloc.categories,
                                            _isCategoriesTabValid(),
                                            context,
                                          ),
                                          Tab(text: gloc.segment_other),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: TabBarView(
                                      controller: _tabController,
                                      children: [
                                        _buildGeneralTab(context),
                                        _buildParticipantsTab(),
                                        _buildCategoriesTab(),
                                        _buildOtherTab(context),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Selector<GroupFormState, bool>(
                          selector: (_, s) => s.isBusy,
                          builder: (ctx, busy, _) {
                            final loc = gen.AppLocalizations.of(ctx);
                            final state = ctx.read<GroupFormState>();
                            final message = state.isSaving
                                ? loc.saving
                                : loc.processing_image;
                            return IgnorePointer(
                              ignoring: !busy,
                              child: AnimatedOpacity(
                                opacity: busy ? 1 : 0,
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutQuad,
                                child: Container(
                                  color: Theme.of(
                                    ctx,
                                  ).colorScheme.surface.withValues(alpha: 0.72),
                                  child: Center(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 260,
                                      ),
                                      switchInCurve: Curves.easeOutBack,
                                      switchOutCurve: Curves.easeIn,
                                      child: !busy
                                          ? const SizedBox.shrink()
                                          : Column(
                                              key: const ValueKey(
                                                'busy_overlay',
                                              ),
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const SizedBox(
                                                  width: 46,
                                                  height: 46,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 3.2,
                                                      ),
                                                ),
                                                const SizedBox(height: 18),
                                                Text(
                                                  message,
                                                  textAlign: TextAlign.center,
                                                  style: Theme.of(ctx)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ], // Stack children
                    ), // Stack
                  ), // Expanded
                  if (widget.mode == GroupEditMode.create)
                    Selector<GroupFormState, bool>(
                      selector: (_, state) => state.isValid,
                      builder: (context, isValid, _) {
                        final gloc = gen.AppLocalizations.of(context);
                        return BottomActionBar(
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;
                            if (_dateError != null) return;

                            final controller = context
                                .read<GroupFormController>();
                            final navigator = Navigator.of(context);
                            ExpenseGroupNotifier? notifier;
                            try {
                              notifier = context.read<ExpenseGroupNotifier>();
                            } catch (_) {
                              notifier = null;
                            }
                            final scaffoldMessenger = ScaffoldMessenger.maybeOf(
                              context,
                            );
                            final gloc = gen.AppLocalizations.of(context);

                            try {
                              final saved = await controller.save();
                              ExpenseGroupStorageV2.forceReload();
                              try {
                                notifier?.notifyGroupUpdated(saved.id);
                              } catch (_) {}

                              // Handle notification state after save
                              final notificationService = NotificationService();
                              if (saved.notificationEnabled &&
                                  context.mounted) {
                                // Show notification for new group
                                await notificationService.showGroupNotification(
                                  saved,
                                  gloc,
                                );
                              }

                              if (navigator.canPop()) navigator.pop(saved.id);
                            } catch (e) {
                              if (scaffoldMessenger != null &&
                                  context.mounted) {
                                AppToast.show(
                                  context,
                                  gloc.backup_error,
                                  type: ToastType.error,
                                );
                              } else if (context.mounted) {
                                AppToast.show(
                                  context,
                                  gloc.backup_error,
                                  type: ToastType.error,
                                );
                              }
                            }
                          },
                          label: gloc.create,
                          enabled: isValid,
                        );
                      },
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
