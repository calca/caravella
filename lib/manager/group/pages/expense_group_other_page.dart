import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/services/notification_service.dart';
import 'package:io_caravella_egm/services/notification_manager.dart';
import '../group_form_controller.dart';
import '../group_edit_mode.dart';
import '../widgets/background_picker.dart';

class ExpenseGroupOtherPage extends StatelessWidget {
  final ExpenseGroup? trip;
  final VoidCallback? onTripDeleted;
  final GroupEditMode mode;

  const ExpenseGroupOtherPage({
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
      child: _OtherPageScaffold(
        trip: trip,
        onTripDeleted: onTripDeleted,
        mode: mode,
      ),
    );
  }
}

class _OtherPageScaffold extends StatefulWidget {
  final ExpenseGroup? trip;
  final VoidCallback? onTripDeleted;
  final GroupEditMode mode;

  const _OtherPageScaffold({
    required this.trip,
    this.onTripDeleted,
    required this.mode,
  });

  @override
  State<_OtherPageScaffold> createState() => _OtherPageScaffoldState();
}

class _OtherPageScaffoldState extends State<_OtherPageScaffold> {
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

  Future<void> _toggleNotification(BuildContext context, bool value) async {
    final gloc = gen.AppLocalizations.of(context);

    final controller = context.read<GroupFormController>();
    final notifier = context.read<ExpenseGroupNotifier>();
    final notificationService = NotificationService();

    // If enabling, request permissions first
    if (value) {
      final granted = await notificationService.requestPermissions();
      if (!granted && context.mounted) {
        AppToast.show(context, gloc.notification_enabled, type: ToastType.info);
        return;
      }
    }

    // Update state and save immediately
    controller.state.setNotificationEnabled(value);

    try {
      final savedGroup = await controller.save();

      // Force repository reload
      ExpenseGroupStorageV2.forceReload();

      // Notify listeners
      if (controller.state.id != null) {
        notifier.notifyGroupUpdated(controller.state.id!);
      }

      // Handle notification based on new value
      if (value && context.mounted) {
        // Show or update notification (with date range check)
        await NotificationManager().updateNotificationForGroup(
          savedGroup,
          gloc,
        );

        if (context.mounted) {
          AppToast.show(
            context,
            gloc.notification_enabled,
            type: ToastType.success,
          );
        }
      } else {
        // Cancel notification for this group
        await NotificationManager().cancelNotificationForGroup(savedGroup.id);

        if (context.mounted) {
          AppToast.show(
            context,
            '${gloc.notification_enabled} ${gloc.accessibility_currently_disabled.toLowerCase()}',
            type: ToastType.info,
          );
        }
      }
    } catch (e, st) {
      // Revert state on error
      controller.state.setNotificationEnabled(!value);

      LoggerService.error(
        'Failed to toggle notification',
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
  }

  Future<void> _toggleAutoLocation(BuildContext context, bool value) async {
    final gloc = gen.AppLocalizations.of(context);

    final controller = context.read<GroupFormController>();
    final notifier = context.read<ExpenseGroupNotifier>();
    controller.state.setAutoLocationEnabled(value);
    try {
      await controller.save();
      if (controller.state.id != null) {
        notifier.notifyGroupUpdated(controller.state.id!);
      }
    } catch (e, st) {
      LoggerService.error(
        'Failed to toggle auto location',
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
  }

  List<Widget> _buildOtherContent(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    return [
      SettingsGroup(
        label: gloc.background,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gloc.choose_image_or_color,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                const BackgroundPicker(),
              ],
            ),
          ),
        ],
      ),
      SettingsGroup(
        children: [
          Selector<GroupFormState, bool>(
            selector: (context, s) => s.notificationEnabled,
            builder: (context, enabled, child) => SettingsTile(
              icon: Icons.notifications_outlined,
              title: gloc.notification_enabled,
              subtitle: gloc.notification_enabled_desc,
              switchValue: enabled,
              onSwitch: (value) => _toggleNotification(context, value),
            ),
          ),
          Selector<GroupFormState, bool>(
            selector: (context, s) => s.autoLocationEnabled,
            builder: (context, enabled, child) => SettingsTile(
              icon: Icons.my_location_outlined,
              title: gloc.settings_auto_location_title,
              subtitle: gloc.settings_auto_location_desc,
              switchValue: enabled,
              onSwitch: (value) => _toggleAutoLocation(context, value),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GroupFormState, int>(
      selector: (_, state) {
        return Object.hash(
          state.imagePath,
          state.color,
          state.autoLocationEnabled,
          state.notificationEnabled,
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
              eyebrow: controller.state.title.isEmpty
                  ? null
                  : controller.state.title,
              title: gen.AppLocalizations.of(context).segment_other,
              children: _buildOtherContent(context),
            ),
          ),
        );
      },
    );
  }
}
