import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/model/expense_group.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../widgets/caravella_app_bar.dart';
import '../../../state/expense_group_notifier.dart';
import '../../../widgets/material3_dialog.dart';
import '../../expense/expense_form/icon_leading_field.dart';
import '../widgets/section_flat.dart';
import '../widgets/section_header.dart';
import '../widgets/selection_tile.dart';
import '../data/group_form_state.dart';
import '../group_form_controller.dart';
import '../widgets/group_title_field.dart';
import '../widgets/participants_editor.dart';
import '../widgets/categories_editor.dart';
import '../widgets/period_section_editor.dart';
import '../widgets/background_picker.dart';
import '../widgets/currency_selector_sheet.dart';
import '../widgets/save_button_bar.dart';
import '../group_edit_mode.dart';
import '../../../settings/user_name_notifier.dart';
import '../../../data/model/expense_participant.dart';

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
          update: (context, state, notifier, previous) =>
              GroupFormController(state, mode, notifier),
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

class _GroupFormScaffoldState extends State<_GroupFormScaffold> {
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
    } else if (widget.mode == GroupEditMode.create) {
      // For new groups, add user as first participant if name is available
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
          );
        },
        builder: (context, _, __) {
          final controller = context.read<GroupFormController>();
          return PopScope(
            canPop: !controller.hasChanges,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              if (controller.hasChanges) {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => Material3Dialog(
                    icon: Icon(
                      Icons.warning_amber_outlined,
                      color: Theme.of(context).colorScheme.error,
                      size: 24,
                    ),
                    title: Text(gloc.discard_changes_title),
                    content: Text(gloc.discard_changes_message),
                    actions: [
                      Material3DialogActions.cancel(ctx, gloc.cancel),
                      Material3DialogActions.destructive(
                        ctx,
                        gloc.discard,
                        onPressed: () => Navigator.of(ctx).pop(true),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  final navigator = Navigator.of(context);
                  if (navigator.canPop()) {
                    navigator.pop(false);
                  }
                }
              }
            },
            child: Scaffold(
          appBar: CaravellaAppBar(actions: []),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: DefaultTextStyle.merge(
                    style: Theme.of(context).textTheme.bodyMedium,
                    child: ListView(
                      children: [
                        Text(
                          widget.mode == GroupEditMode.edit
                              ? gloc.edit_group
                              : gloc.new_group,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 24),
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
                                  IconLeadingField(
                                    icon: const Icon(Icons.title_outlined),
                                    semanticsLabel: gloc.group_name,
                                    tooltip: gloc.group_name,
                                    child: const GroupTitleField(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const ParticipantsEditor(),
                        const SizedBox(height: 24),
                        const CategoriesEditor(),
                        const SizedBox(height: 24),
                        PeriodSectionEditor(
                          onPickDate: (isStart) async =>
                              _pickDate(context, isStart),
                          onClearDates: _clearDates,
                          errorText: _dateError,
                        ),
                        const SizedBox(height: 24),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(fontSize: 28),
                                      semanticsLabel:
                                          '${cur['symbol']} ${cur['code']}',
                                    ),
                                    title: cur['name']!,
                                    subtitle: '${cur['code']}',
                                    trailing: Icon(
                                      Icons.chevron_right,
                                      size: 24,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                    ),
                                    onTap: () async {
                                      final selected =
                                          await showModalBottomSheet<
                                            Map<String, String>
                                          >(
                                            context: context,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(20),
                                                  ),
                                            ),
                                            builder: (_) =>
                                                const CurrencySelectorSheet(),
                                          );
                                      if (selected != null && context.mounted) {
                                        context
                                            .read<GroupFormState>()
                                            .setCurrency(selected);
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
                            const SizedBox(height: 32),
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
                          ],
                        ),
                        const SizedBox(height: 32),
                        const SaveButtonBar(),
                        const SizedBox(height: 80),
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
                            duration: const Duration(milliseconds: 260),
                            switchInCurve: Curves.easeOutBack,
                            switchOutCurve: Curves.easeIn,
                            child: !busy
                                ? const SizedBox.shrink()
                                : Column(
                                    key: const ValueKey('busy_overlay'),
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 46,
                                        height: 46,
                                        child: CircularProgressIndicator(
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
                                              fontWeight: FontWeight.w600,
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
            ],
          ),
        ),
        );
      },
      ),
    );
  }
}
