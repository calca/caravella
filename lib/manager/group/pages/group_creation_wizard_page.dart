import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import '../data/group_form_state.dart';
import '../group_form_controller.dart';
import '../group_edit_mode.dart';
import '../group_type/group_type_localization.dart';
import '../wizard/wizard_steps/wizard_user_name_step.dart';
import '../wizard/wizard_steps/wizard_type_step.dart';
import '../wizard/wizard_steps/wizard_details_step.dart';
import '../wizard/wizard_steps/wizard_people_step.dart';
import '../../details/pages/expense_group_detail_page.dart';

/// The steps of [GroupCreationWizardPage], in order.
enum WizardStep { userName, type, details, people }

/// Creates a group in short steps, in the app's style (grey page, round back
/// button, segmented progress, wide green button):
/// your name (first start only) → what kind of group → its name (dates,
/// currency) → who shares the expenses. Then it saves and leaves: from the
/// welcome screen back to Home (which shows the new group with its
/// getting-started checklist), otherwise into the new group's page.
class GroupCreationWizardPage extends StatefulWidget {
  /// Launched from the welcome screen: asks for the user's name first (when
  /// not set yet) and returns to Home with the new group's id.
  final bool fromWelcome;

  const GroupCreationWizardPage({super.key, this.fromWelcome = false});

  @override
  State<GroupCreationWizardPage> createState() =>
      _GroupCreationWizardPageState();
}

class _GroupCreationWizardPageState extends State<GroupCreationWizardPage> {
  late final bool _includeUserNameStep;

  @override
  void initState() {
    super.initState();
    // Decided once, so the steps don't change while the wizard runs.
    final userNameNotifier = context.read<UserNameNotifier>();
    _includeUserNameStep = widget.fromWelcome && !userNameNotifier.hasName;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GroupFormState()),
        ChangeNotifierProvider(
          create: (_) => WizardState(includeUserNameStep: _includeUserNameStep),
        ),
        ProxyProvider2<
          GroupFormState,
          ExpenseGroupNotifier,
          GroupFormController
        >(
          update: (context, state, notifier, previous) =>
              GroupFormController(state, GroupEditMode.create, notifier),
        ),
      ],
      child: _WizardScaffold(fromWelcome: widget.fromWelcome),
    );
  }
}

class WizardState extends ChangeNotifier {
  int _currentStep = 0;
  final PageController pageController = PageController();
  final bool includeUserNameStep;

  WizardState({this.includeUserNameStep = true});

  List<WizardStep> get steps => [
    if (includeUserNameStep) WizardStep.userName,
    WizardStep.type,
    WizardStep.details,
    WizardStep.people,
  ];

  int get currentStep => _currentStep;
  int get totalSteps => steps.length;
  WizardStep get step => steps[_currentStep];
  bool get isLastStep => _currentStep == totalSteps - 1;

  void nextStep() => _goTo(_currentStep + 1);
  void previousStep() => _goTo(_currentStep - 1);

  void _goTo(int step) {
    if (step < 0 || step >= totalSteps || step == _currentStep) return;
    _currentStep = step;
    notifyListeners();
    if (pageController.hasClients) {
      pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

class _WizardScaffold extends StatefulWidget {
  final bool fromWelcome;

  const _WizardScaffold({this.fromWelcome = false});

  @override
  State<_WizardScaffold> createState() => _WizardScaffoldState();
}

class _WizardScaffoldState extends State<_WizardScaffold> {
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // The user is the first participant (their name, or the localized "Me"),
    // and the default type's categories are there from the start.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userNameNotifier = context.read<UserNameNotifier>();
      final state = context.read<GroupFormState>();
      final controller = context.read<GroupFormController>();
      final gloc = gen.AppLocalizations.of(context);

      state.addParticipant(
        ExpenseParticipant(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: userNameNotifier.hasName
              ? userNameNotifier.name
              : gloc.default_participant_me,
        ),
      );
      if (state.groupType != null) {
        controller.initializeDefaultCategories(
          GroupTypeLocalization.localizedDefaultCategories(
            gloc,
            state.groupType!,
          ),
        );
      }
    });
  }

  bool _canContinue(WizardState wizard, GroupFormState state) =>
      wizard.step != WizardStep.details || state.title.trim().isNotEmpty;

  /// Leaving the name step: the user's name replaces the "Me" placeholder.
  void _applyUserName() {
    final user = context.read<UserNameNotifier>();
    if (!user.hasName) return;
    final state = context.read<GroupFormState>();
    final me = gen.AppLocalizations.of(context).default_participant_me;
    final i = state.participants.indexWhere(
      (p) => p.name.trim().toLowerCase() == me.trim().toLowerCase(),
    );
    if (i != -1) state.editParticipant(i, user.name);
  }

  Future<void> _next(WizardState wizard) async {
    FocusScope.of(context).unfocus();
    if (wizard.step == WizardStep.userName) _applyUserName();
    if (!wizard.isLastStep) {
      wizard.nextStep();
      return;
    }
    await _create();
  }

  Future<void> _create() async {
    if (_saving) return;
    setState(() => _saving = true);
    final controller = context.read<GroupFormController>();
    final gloc = gen.AppLocalizations.of(context);
    try {
      final group = await controller.save();
      await PreferencesService.instance.appState.setIsFirstStart(false);
      if (!mounted) return;
      final nav = Navigator.of(context);
      nav.pop(group.id);
      // From Groups (or Home's "+"): straight into the new group.
      if (!widget.fromWelcome) {
        await nav.push(
          MaterialPageRoute(
            builder: (_) => ExpenseGroupDetailPage(trip: group),
          ),
        );
      }
    } catch (e, st) {
      LoggerService.error(
        'Group creation failed',
        name: 'manager.group',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        setState(() => _saving = false);
        AppToast.show(
          context,
          gloc.error_saving_group(e.toString()),
          type: ToastType.error,
        );
      }
    }
  }

  /// Back: the previous step, or out of the wizard (asking first when
  /// something was entered).
  Future<void> _back(WizardState wizard) async {
    FocusScope.of(context).unfocus();
    if (wizard.currentStep > 0) {
      wizard.previousStep();
      return;
    }
    if (await _confirmDiscard() && mounted) Navigator.of(context).pop();
  }

  Future<bool> _confirmDiscard() async {
    final controller = context.read<GroupFormController>();
    if (!controller.hasChanges) return true;
    final gloc = gen.AppLocalizations.of(context);
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
    return confirm == true;
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final wizard = context.watch<WizardState>();

    return AppSystemUI.surfaceContainer(
      context: context,
      // Back is always handled here: the step or the discard question.
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _back(wizard);
        },
        child: Scaffold(
          backgroundColor: s.surfaceContainer,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 24, 0),
                  child: Row(
                    children: [
                      RoundBackButton(onPressed: () => _back(wizard)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StepProgress(
                          current: wizard.currentStep,
                          total: wizard.totalSteps,
                          label:
                              '${wizard.currentStep + 1}/${wizard.totalSteps}',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: wizard.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (final (i, step) in wizard.steps.indexed)
                        // Off-screen steps are out of the focus order.
                        ExcludeFocus(
                          excluding: wizard.currentStep != i,
                          child: FocusTraversalGroup(
                            child: switch (step) {
                              WizardStep.userName => WizardUserNameStep(
                                onSubmitted: () => _next(wizard),
                              ),
                              WizardStep.type => const WizardTypeStep(),
                              WizardStep.details => WizardDetailsStep(
                                onSubmitted: () => _next(wizard),
                              ),
                              WizardStep.people => const WizardPeopleStep(),
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Consumer<GroupFormState>(
                    builder: (context, state, _) {
                      final enabled = !_saving && _canContinue(wizard, state);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FilledButton(
                            onPressed: enabled ? () => _next(wizard) : null,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ),
                            child: _saving
                                ? SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: s.onPrimary,
                                    ),
                                  )
                                : Text(
                                    wizard.isLastStep
                                        ? gloc.wizard_create
                                        : gloc.wizard_continue,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: enabled
                                          ? s.onPrimary
                                          : s.onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                          if (wizard.step == WizardStep.userName)
                            TextButton(
                              onPressed: () => _next(wizard),
                              style: TextButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                              ),
                              child: Text(gloc.wizard_skip),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The wizard's progress: one segment per step, filled up to the current
/// one; screen readers hear "2/4".
class _StepProgress extends StatelessWidget {
  final int current;
  final int total;
  final String label;

  const _StepProgress({
    required this.current,
    required this.total,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 6,
                decoration: BoxDecoration(
                  color: i <= current ? s.primary : s.outlineVariant,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shared layout of a wizard step: a small eyebrow, a big question, then the
/// step's content; scrolls when the keyboard is up.
class WizardStepLayout extends StatelessWidget {
  final String eyebrow;
  final String title;
  final List<Widget> children;

  const WizardStepLayout({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            eyebrow,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Semantics(
            header: true,
            child: Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}

/// Small grey note under a step's content.
class WizardNote extends StatelessWidget {
  final String text;
  final IconData? icon;

  const WizardNote(this.text, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

/// A raised white card on the wizard's grey page (like the expense form's).
class WizardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const WizardCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 20, 12),
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    return CardOutline(
      borderRadius: radius,
      child: Material(
        color: Theme.of(context).colorScheme.raisedSurface,
        borderRadius: radius,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
