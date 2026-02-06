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

  Widget _buildOtherContent(BuildContext context) {
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
                    description: gloc.notification_enabled_desc,
                    padding: EdgeInsets.zero,
                    spacing: 4,
                  ),
                  const SizedBox(height: 12),
                  Selector<GroupFormState, bool>(
                    selector: (context, s) => s.notificationEnabled,
                    builder: (context, enabled, child) => Semantics(
                      toggled: enabled,
                      label:
                          '${gloc.notification_enabled_desc} - ${enabled ? gloc.accessibility_currently_enabled : gloc.accessibility_currently_disabled}',
                      hint: gloc.notification_enabled_desc,
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
                          final notifier = context.read<ExpenseGroupNotifier>();
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
                              await NotificationManager()
                                  .updateNotificationForGroup(savedGroup, gloc);

                              if (context.mounted) {
                                AppToast.show(
                                  context,
                                  gloc.notification_enabled,
                                  type: ToastType.success,
                                );
                              }
                            } else {
                              // Cancel notification for this group
                              await NotificationManager()
                                  .cancelNotificationForGroup(savedGroup.id);

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
              title: Text(gloc.segment_other),
              actions: const [],
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildOtherContent(context),
            ),
          ),
        );
      },
    );
  }
}
