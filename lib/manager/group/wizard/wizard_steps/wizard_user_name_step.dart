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

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Friendly emoji icon
            Text('👋', style: const TextStyle(fontSize: 72)),

            const SizedBox(height: 24),

            // Friendly message
            Text(
              gloc.wizard_user_name_welcome,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Step description
            Text(
              gloc.wizard_user_name_description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Compact input with icon
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: gloc.wizard_user_name_hint,
                  prefixIcon: Icon(
                    Icons.person_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.next,
                autofocus: true,
              ),
            ),

            const SizedBox(height: 20),

            // Compact privacy note
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      gloc.wizard_user_name_local_storage_note,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
