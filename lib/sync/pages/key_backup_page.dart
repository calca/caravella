import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/key_backup_service.dart';
import '../../data/services/logger_service.dart';
import '../../widgets/toast.dart';

/// Page for backing up and restoring encryption keys
class KeyBackupPage extends StatefulWidget {
  const KeyBackupPage({super.key});

  @override
  State<KeyBackupPage> createState() => _KeyBackupPageState();
}

class _KeyBackupPageState extends State<KeyBackupPage> {
  final _backupService = KeyBackupService();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isCreatingBackup = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createBackup() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty) {
      AppToast.show(
        context,
        'Please enter a password',
        type: ToastType.error,
      );
      return;
    }

    if (password != confirmPassword) {
      AppToast.show(
        context,
        'Passwords do not match',
        type: ToastType.error,
      );
      return;
    }

    if (password.length < 8) {
      AppToast.show(
        context,
        'Password must be at least 8 characters',
        type: ToastType.error,
      );
      return;
    }

    setState(() => _isCreatingBackup = true);

    try {
      final backup = await _backupService.createBackup(password);

      if (backup == null) {
        if (mounted) {
          AppToast.show(
            context,
            'No groups to backup',
            type: ToastType.info,
          );
        }
        return;
      }

      // Save to file and share
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/caravella_backup_$timestamp.key');
      await file.writeAsString(backup);

      if (!mounted) return;

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Caravella Encryption Key Backup\n\n'
            'This file contains your encrypted group keys. '
            'Keep it safe and remember your password.',
      );

      if (!mounted) return;

      AppToast.show(
        context,
        'Backup created successfully',
        type: ToastType.success,
      );

      _passwordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      LoggerService.error('Failed to create backup: $e');
      if (mounted) {
        AppToast.show(
          context,
          'Failed to create backup',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingBackup = false);
      }
    }
  }

  Future<void> _showRestoreDialog() async {
    final gloc = gen.AppLocalizations.of(context);
    final passwordController = TextEditingController();
    final backupController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore from Backup'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: backupController,
                decoration: const InputDecoration(
                  labelText: 'Paste backup data',
                  hintText: 'Long press to paste',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Backup Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(gloc.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _restoreBackup(
                backupController.text,
                passwordController.text,
              );
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreBackup(String backupData, String password) async {
    if (backupData.trim().isEmpty || password.isEmpty) {
      AppToast.show(
        context,
        'Please provide both backup data and password',
        type: ToastType.error,
      );
      return;
    }

    try {
      final success = await _backupService.restoreFromBackup(
        backupData.trim(),
        password,
      );

      if (!mounted) return;

      if (success) {
        AppToast.show(
          context,
          'Keys restored successfully',
          type: ToastType.success,
        );
      } else {
        AppToast.show(
          context,
          'Failed to restore - wrong password or invalid backup',
          type: ToastType.error,
        );
      }
    } catch (e) {
      LoggerService.error('Failed to restore backup: $e');
      if (mounted) {
        AppToast.show(
          context,
          'Failed to restore backup',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Key Backup & Recovery'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Create a backup of your encryption keys. '
                        'You will need this backup if you lose all your devices.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Create Backup section
            Text(
              'Create Backup',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Backup Password',
                hintText: 'Enter a strong password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              obscureText: _obscurePassword,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Re-enter password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  },
                ),
              ),
              obscureText: _obscureConfirm,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isCreatingBackup ? null : _createBackup,
              icon: _isCreatingBackup
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.backup),
              label: const Text('Create Backup'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 48),

            // Restore section
            Text(
              'Restore from Backup',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _showRestoreDialog,
              icon: const Icon(Icons.restore),
              label: const Text('Restore Keys'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 32),

            // Security warning
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_outlined,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Important',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Store your backup in a safe place\n'
                      '• Remember your backup password\n'
                      '• Without the backup, you cannot recover keys\n'
                      '• Anyone with the backup and password can access your data',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
