// Widget simile a quello incollato per la selezione valuta
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/expense_group.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import '../../widgets/caravella_app_bar.dart';
import '../expense/expense_form/icon_leading_field.dart';
import '../../themes/app_text_styles.dart';
import 'widgets/section_flat.dart';
import 'widgets/selection_tile.dart';
import 'refactor/group_form_state.dart';
import 'refactor/group_form_controller.dart';
import 'refactor/widgets/group_title_field.dart';
import 'refactor/widgets/participants_editor.dart';
import 'refactor/widgets/categories_editor.dart';
import 'refactor/widgets/period_section_editor.dart';
import 'refactor/widgets/background_picker.dart';
import 'refactor/widgets/currency_selector_sheet.dart';
import 'refactor/widgets/save_button_bar.dart';

class AddNewExpensesGroupPage extends StatelessWidget {
  final ExpenseGroup? trip;
  final VoidCallback? onTripDeleted;
  const AddNewExpensesGroupPage({super.key, this.trip, this.onTripDeleted});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GroupFormState()),
        ProxyProvider<GroupFormState, GroupFormController>(
          update: (context, state, previous) => GroupFormController(state),
        ),
      ],
      child: _GroupFormScaffold(trip: trip, onTripDeleted: onTripDeleted),
    );
  }
}

class _GroupFormScaffold extends StatefulWidget {
  final ExpenseGroup? trip;
  final VoidCallback? onTripDeleted;
  const _GroupFormScaffold({required this.trip, this.onTripDeleted});
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
    if (widget.trip != null) {
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
      if (isStart && _state.endDate != null) return !d.isAfter(_state.endDate!);
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
      child: PopScope(
        canPop: !_controller.hasChanges,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (_controller.hasChanges) {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(gloc.discard_changes_title),
                content: Text(gloc.discard_changes_message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(gloc.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(gloc.discard),
                  ),
                ],
              ),
            );
            if (confirm == true && context.mounted) {
              final navigator = Navigator.of(context);
              if (navigator.canPop()) navigator.pop(false);
            }
          }
        },
        child: Scaffold(
          appBar: CaravellaAppBar(
            actions: [
              if (widget.trip != null)
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: gloc.delete,
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (d) => AlertDialog(
                        title: Text(gloc.delete_trip),
                        content: Text(gloc.delete_trip_confirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(d).pop(false),
                            child: Text(gloc.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(d).pop(true),
                            child: Text(gloc.delete),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _controller.deleteGroup();
                      if (mounted && nav.canPop()) {
                        nav.pop(true);
                      }
                      if (widget.onTripDeleted != null) {
                        Future.microtask(() => widget.onTripDeleted!.call());
                      }
                    }
                  },
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: DefaultTextStyle.merge(
                style: Theme.of(context).textTheme.bodyMedium,
                child: ListView(
                  children: [
                    Text(
                      widget.trip != null ? gloc.edit_group : gloc.new_group,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 24),
                    SectionFlat(
                      title: '',
                      children: [
                        IconLeadingField(
                          icon: const Icon(Icons.title_outlined),
                          semanticsLabel: gloc.group_name,
                          tooltip: gloc.group_name,
                          child: const GroupTitleField(),
                        ),
                        Selector<GroupFormState, String>(
                          selector: (context, s) => s.title,
                          builder: (context, title, child) => title.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    '* ${gloc.enter_title}',
                                    style: AppTextStyles.listItem(context)
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                        ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        if (_dateError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _dateError!,
                              style: AppTextStyles.listItem(context)?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
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
                    ),
                    const SizedBox(height: 24),
                    SectionFlat(
                      title: '',
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gloc.currency,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Selector<GroupFormState, Map<String, String>>(
                              selector: (context, s) => s.currency,
                              builder: (context, cur, child) => SelectionTile(
                                leading: const Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 32,
                                ),
                                title: cur['name']!,
                                subtitle: '0${cur['symbol']} ${cur['code']}',
                                trailing: Icon(
                                  Icons.chevron_right,
                                  size: 24,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                onTap: () => showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (_) => const CurrencySelectorSheet(),
                                ),
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
                            Text(
                              gloc.background,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              gloc.choose_image_or_color,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[700]),
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
        ),
      ),
    );
  }
}
