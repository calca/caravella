import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/model/expense_group.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../widgets/caravella_app_bar.dart';
import '../../../state/expense_group_notifier.dart';
import '../../../widgets/material3_dialog.dart';
import '../data/group_form_state.dart';
import '../group_form_controller.dart';
import '../group_edit_mode.dart';
import '../../../settings/user_name_notifier.dart';
import '../../../data/model/expense_participant.dart';
import '../widgets/wizard_step_indicator.dart';
import '../widgets/wizard_navigation_bar.dart';
import '../widgets/wizard_steps/wizard_name_step.dart';
import '../widgets/wizard_steps/wizard_participants_step.dart';
import '../widgets/wizard_steps/wizard_categories_step.dart';
import '../widgets/wizard_steps/wizard_period_step.dart';
import '../widgets/wizard_steps/wizard_background_step.dart';
import '../widgets/wizard_steps/wizard_congratulations_step.dart';

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

  int get currentStep => _currentStep;
  PageController get pageController => _pageController;
  
  // Total number of wizard steps
  static const int totalSteps = 6;

  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      _currentStep = step;
      _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userNameNotifier = context.read<UserNameNotifier>();
        final state = context.read<GroupFormState>();
        if (userNameNotifier.hasName) {
          state.addParticipant(ExpenseParticipant(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: userNameNotifier.name,
          ));
        }
      }
    });
  }

  bool _canPop() {
    final formState = context.read<GroupFormState>();
    final controller = context.read<GroupFormController>();
    return !controller.hasChanges;
  }

  Future<bool> _onWillPop() async {
    final gloc = gen.AppLocalizations.of(context);
    final formState = context.read<GroupFormState>();
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
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop(false);
          }
        }
      },
      child: Scaffold(
        appBar: CaravellaAppBar(
          title: Text(gloc.wizard_group_creation_title),
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
                    onPageChanged: (index) {
                      // Update the current step when page changes
                      if (wizardState._currentStep != index) {
                        wizardState._currentStep = index;
                        wizardState.notifyListeners();
                      }
                    },
                    children: const [
                      WizardNameStep(),
                      WizardParticipantsStep(),
                      WizardCategoriesStep(),
                      WizardPeriodStep(),
                      WizardBackgroundStep(),
                      WizardCongratulationsStep(),
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