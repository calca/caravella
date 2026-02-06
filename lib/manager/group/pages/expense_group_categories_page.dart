import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/services/notification_manager.dart';
import '../group_form_controller.dart';
import '../group_edit_mode.dart';
import '../widgets/categories_editor.dart';

class ExpenseGroupCategoriesPage extends StatelessWidget {
  final ExpenseGroup? trip;
  final VoidCallback? onTripDeleted;
  final GroupEditMode mode;

  const ExpenseGroupCategoriesPage({
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
      child: _CategoriesPageScaffold(
        trip: trip,
        onTripDeleted: onTripDeleted,
        mode: mode,
      ),
    );
  }
}

class _CategoriesPageScaffold extends StatefulWidget {
  final ExpenseGroup? trip;
  final VoidCallback? onTripDeleted;
  final GroupEditMode mode;

  const _CategoriesPageScaffold({
    required this.trip,
    this.onTripDeleted,
    required this.mode,
  });

  @override
  State<_CategoriesPageScaffold> createState() =>
      _CategoriesPageScaffoldState();
}

class _CategoriesPageScaffoldState extends State<_CategoriesPageScaffold> {
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

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    return Selector<GroupFormState, int>(
      selector: (_, state) {
        return Object.hash(
          state.categories.length,
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
              final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
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

                if (scaffoldMessenger != null && context.mounted) {
                  AppToast.show(
                    context,
                    gloc.error_saving_group(e.toString()),
                    type: ToastType.error,
                  );
                } else if (context.mounted) {
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
              title: Text(gloc.categories),
              actions: const [],
            ),
            body: const Padding(
              padding: EdgeInsets.all(20.0),
              child: CategoriesEditor(),
            ),
          ),
        );
      },
    );
  }
}
