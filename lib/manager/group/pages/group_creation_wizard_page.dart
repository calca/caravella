import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import '../data/group_form_state.dart';
import '../group_form_controller.dart';
import '../group_edit_mode.dart';
import '../wizard/wizard_step_indicator.dart';
import '../wizard/wizard_navigation_bar.dart';
import '../wizard/wizard_steps/wizard_user_name_step.dart';
import '../wizard/wizard_steps/wizard_type_and_name_step.dart';
import '../wizard/wizard_steps/wizard_completion_step.dart';
import '../../details/pages/expense_group_detail_page.dart';

class GroupCreationWizardPage extends StatefulWidget {
  /// If true, shows the user name step when launched from welcome page
  /// (only if user name is not already set)
  /// Also affects the completion step navigation behavior
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
    // Calculate includeUserNameStep once at initialization and keep it stable
    // during the wizard execution to avoid PageView structure changes
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
  late final PageController _pageController;
  String? _savedGroupId;
  final bool includeUserNameStep;

  WizardState({this.includeUserNameStep = true}) {
    _pageController = PageController(initialPage: 0);
  }

  int get currentStep => _currentStep;
  PageController get pageController => _pageController;
  String? get savedGroupId => _savedGroupId;

  // Total number of wizard steps (dynamic based on whether user name step is included)
  int get totalSteps => includeUserNameStep ? 3 : 2;

  void setSavedGroupId(String groupId) {
    _savedGroupId = groupId;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
      final targetStep = _currentStep;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            targetStep,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
      final targetStep = _currentStep;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            targetStep,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      if (step != _currentStep) {
        _currentStep = step;
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            step,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        notifyListeners();
      }
    }
  }

  void syncWithPage(int step) {
    if (step >= 0 && step < totalSteps && step != _currentStep) {
      _currentStep = step;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
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
  @override
  void initState() {
    super.initState();
    // Add user as first participant (using their name if set, or localized "Me")
    // and initialize default categories based on the default group type
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userNameNotifier = context.read<UserNameNotifier>();
        final state = context.read<GroupFormState>();
        final controller = context.read<GroupFormController>();
        final gloc = gen.AppLocalizations.of(context);

        final participantName = userNameNotifier.hasName
            ? userNameNotifier.name
            : gloc.default_participant_me;
        state.addParticipant(
          ExpenseParticipant(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: participantName,
          ),
        );

        // Initialize default categories for the default group type
        if (state.groupType != null) {
          final defaultCategories = _getLocalizedCategories(
            gloc,
            state.groupType!,
          );
          controller.initializeDefaultCategories(defaultCategories);
        }
      }
    });
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

  bool _canPop(WizardState wizardState) {
    // Cannot go back from completion step - back gesture triggers CTA action
    if (wizardState.currentStep == wizardState.totalSteps - 1) {
      return false;
    }
    final controller = context.read<GroupFormController>();
    return !controller.hasChanges;
  }

  Future<void> _handleCompletionBackAction(WizardState wizardState) async {
    // When on completion step, back gesture acts like the CTA button
    final groupId = wizardState.savedGroupId;
    if (groupId == null) {
      Navigator.of(context).pop();
      return;
    }

    if (widget.fromWelcome) {
      // When coming from welcome, pop back with groupId so home can refresh
      Navigator.of(context).pop(groupId);
    } else {
      // When coming from home with existing groups,
      // navigate to the newly created group detail page
      final group = await ExpenseGroupStorageV2.getTripById(groupId);
      if (group != null && mounted) {
        // Capture navigator before pop to avoid detached context
        final nav = Navigator.of(context);
        nav.pop();
        await nav.push(
          MaterialPageRoute(
            builder: (context) => ExpenseGroupDetailPage(trip: group),
          ),
        );
      } else if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<bool> _onWillPop() async {
    final wizardState = context.read<WizardState>();
    // Prevent going back from completion step
    if (wizardState.currentStep == wizardState.totalSteps - 1) {
      return false;
    }

    final gloc = gen.AppLocalizations.of(context);
    final controller = context.read<GroupFormController>();

    if (!controller.hasChanges) return true;

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

    return Consumer<WizardState>(
      builder: (context, wizardState, child) {
        final isCompletionStep =
            wizardState.currentStep == wizardState.totalSteps - 1;

        return AppSystemUI.surface(
          child: PopScope(
            canPop: _canPop(wizardState),
            onPopInvokedWithResult: (didPop, _) async {
              if (!didPop) {
                if (isCompletionStep) {
                  // On completion step, back gesture triggers CTA action
                  await _handleCompletionBackAction(wizardState);
                } else {
                  final shouldPop = await _onWillPop();
                  if (shouldPop && context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(gloc.wizard_group_creation_title),
                elevation: 0,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                // Hide back button on completion step
                automaticallyImplyLeading: !isCompletionStep,
                leading: isCompletionStep ? const SizedBox.shrink() : null,
              ),
              body: Column(
                children: [
                  // Step indicator
                  const WizardStepIndicator(),

                  // Wizard content
                  Expanded(
                    child: PageView(
                      controller: wizardState.pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        wizardState.syncWithPage(index);
                      },
                      children: [
                        if (wizardState.includeUserNameStep)
                          const WizardUserNameStep(),
                        const WizardTypeAndNameStep(),
                        WizardCompletionStep(
                          groupId: wizardState.savedGroupId ?? '',
                          fromWelcome: widget.fromWelcome,
                        ),
                      ],
                    ),
                  ),

                  // Navigation bar
                  const WizardNavigationBar(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
