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

class GroupCreationWizardPage extends StatelessWidget {
  const GroupCreationWizardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GroupFormState()),
        ChangeNotifierProvider(create: (_) => WizardState()),
        ProxyProvider2<
          GroupFormState,
          ExpenseGroupNotifier,
          GroupFormController
        >(
          update: (context, state, notifier, previous) =>
              GroupFormController(state, GroupEditMode.create, notifier),
        ),
      ],
      child: const _WizardScaffold(),
    );
  }
}

class WizardState extends ChangeNotifier {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  String? _savedGroupId;

  int get currentStep => _currentStep;
  PageController get pageController => _pageController;
  String? get savedGroupId => _savedGroupId;

  // Total number of wizard steps
  static const int totalSteps = 3;

  void setSavedGroupId(String groupId) {
    _savedGroupId = groupId;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      if (_pageController.hasClients) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      notifyListeners();
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
  const _WizardScaffold();

  @override
  State<_WizardScaffold> createState() => _WizardScaffoldState();
}

class _WizardScaffoldState extends State<_WizardScaffold> {
  @override
  void initState() {
    super.initState();
    // Add user as first participant if name is available
    // and skip the user name step if already set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userNameNotifier = context.read<UserNameNotifier>();
        final state = context.read<GroupFormState>();
        final wizardState = context.read<WizardState>();
        if (userNameNotifier.hasName) {
          state.addParticipant(
            ExpenseParticipant(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: userNameNotifier.name,
            ),
          );
          // Skip to step 1 (type and name) if user name already exists
          wizardState.goToStep(1);
        }
      }
    });
  }

  bool _canPop() {
    final controller = context.read<GroupFormController>();
    return !controller.hasChanges;
  }

  Future<bool> _onWillPop() async {
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

    return PopScope(
      canPop: _canPop(),
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop(false);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(gloc.wizard_group_creation_title),
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: Column(
          children: [
            // Step indicator
            const WizardStepIndicator(),

            // Wizard content
            Expanded(
              child: Consumer<WizardState>(
                builder: (context, wizardState, child) {
                  return PageView(
                    controller: wizardState.pageController,
                    physics: wizardState.currentStep == 2
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    onPageChanged: (index) {
                      wizardState.syncWithPage(index);
                    },
                    children: [
                      const WizardUserNameStep(),
                      const WizardTypeAndNameStep(),
                      WizardCompletionStep(
                        groupId: wizardState.savedGroupId ?? '',
                      ),
                    ],
                  );
                },
              ),
            ),

            // Navigation bar
            const WizardNavigationBar(),
          ],
        ),
      ),
    );
  }
}
