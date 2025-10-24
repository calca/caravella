import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/expense_group_notifier.dart';
import '../../../data/expense_group_storage_v2.dart';
import '../../../data/services/notification_service.dart';
import '../data/group_form_state.dart';
import '../group_form_controller.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

class SaveButtonBar extends StatelessWidget {
  const SaveButtonBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GroupFormState>();
    final controller = context.read<GroupFormController>();
    final loc = gen.AppLocalizations.of(context);
    final saving = state.isSaving;
    final hasChanges = controller.hasChanges;
    return FilledButton(
      onPressed: state.isValid && !saving && hasChanges
          ? () async {
              // Capture context-dependent values before any awaits
              final navigator = Navigator.of(context);
              ExpenseGroupNotifier? notifier;
              try {
                notifier = context.read<ExpenseGroupNotifier>();
              } catch (_) {
                notifier = null;
              }

              final saved = await controller.save();

              // Force repository reload so subsequent reads fetch latest data
              ExpenseGroupStorageV2.forceReload();

              // Handle notification based on the saved group settings
              final notificationService = NotificationService();
              if (saved.notificationEnabled) {
                // Request permissions if needed
                await notificationService.requestPermissions();
                // Show or update notification
                await notificationService.showGroupNotification(saved, loc);
              } else {
                // Cancel notification if disabled
                await notificationService.cancelGroupNotification();
              }

              // Notify global notifier about the updated/added group so UI can react
              try {
                notifier?.notifyGroupUpdated(saved.id);
              } catch (_) {
                // ignore if notifier not available
              }

              Future.microtask(() {
                if (navigator.context.mounted) {
                  navigator.pop(true);
                }
              });
            }
          : null,
      child: saving
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(loc.saving),
              ],
            )
          : Text(loc.save),
    );
  }
}
