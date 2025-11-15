import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';

class WizardUserNameStep extends StatefulWidget {
  const WizardUserNameStep({super.key});

  @override
  State<WizardUserNameStep> createState() => _WizardUserNameStepState();
}

class _WizardUserNameStepState extends State<WizardUserNameStep> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userNameNotifier = context.read<UserNameNotifier>();
        if (userNameNotifier.hasName) {
          _controller.text = userNameNotifier.name;
        }
      }
    });

    _controller.addListener(() {
      // Save name automatically when user types
      if (_controller.text.trim().isNotEmpty) {
        final userNameNotifier = context.read<UserNameNotifier>();
        userNameNotifier.setName(_controller.text.trim());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Friendly message
          Text(
            gloc.wizard_user_name_welcome,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 16),

          // Step description
          Text(
            gloc.wizard_user_name_description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 8),

          // Local storage note with emoji
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text('😊', style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    gloc.wizard_user_name_local_storage_note,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Name input
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: gloc.wizard_user_name_label,
              hintText: gloc.wizard_user_name_hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(
                Icons.person_outline,
                color: theme.colorScheme.primary,
              ),
            ),
            textInputAction: TextInputAction.next,
          ),

          const Spacer(),

          // Visual hint
          Center(
            child: Icon(
              Icons.person_add_outlined,
              size: 120,
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
