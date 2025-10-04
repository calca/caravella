import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../data/model/expense_group.dart';
import '../../data/services/logger_service.dart';
import '../models/device_info.dart';
import '../services/device_management_service.dart';
import '../../widgets/toast.dart';

/// Page to manage devices that have access to a group
class DeviceManagementPage extends StatefulWidget {
  final ExpenseGroup group;

  const DeviceManagementPage({
    super.key,
    required this.group,
  });

  @override
  State<DeviceManagementPage> createState() => _DeviceManagementPageState();
}

class _DeviceManagementPageState extends State<DeviceManagementPage> {
  final _deviceService = DeviceManagementService();
  List<DeviceInfo>? _devices;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    try {
      final devices = await _deviceService.getDevicesForGroup(widget.group.id);
      if (mounted) {
        setState(() {
          _devices = devices;
          _isLoading = false;
        });
      }
    } catch (e) {
      LoggerService.error('Failed to load devices: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _revokeDevice(DeviceInfo device) async {
    final gloc = gen.AppLocalizations.of(context);
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke Device Access'),
        content: Text(
          'Are you sure you want to revoke access for "${device.deviceName}"? '
          'This device will no longer be able to sync this group.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(gloc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Revoke device
    final success = await _deviceService.revokeDevice(
      widget.group.id,
      device.deviceId,
    );

    if (!mounted) return;

    if (success) {
      AppToast.show(
        context,
        'Device access revoked',
        type: ToastType.success,
      );
      await _loadDevices();
    } else {
      AppToast.show(
        context,
        'Failed to revoke device access',
        type: ToastType.error,
      );
    }
  }

  Future<void> _renameDevice(DeviceInfo device) async {
    final controller = TextEditingController(text: device.deviceName);
    
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Device'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Device Name',
            hintText: 'Enter new device name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName == null || newName.trim().isEmpty || newName == device.deviceName) {
      return;
    }

    final success = await _deviceService.renameDevice(
      widget.group.id,
      device.deviceId,
      newName.trim(),
    );

    if (!mounted) return;

    if (success) {
      AppToast.show(
        context,
        'Device renamed',
        type: ToastType.success,
      );
      await _loadDevices();
    } else {
      AppToast.show(
        context,
        'Failed to rename device',
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _devices == null || _devices!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.devices_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No devices found',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDevices,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _devices!.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildInfoCard(theme);
                      }
                      
                      final device = _devices![index - 1];
                      return _buildDeviceCard(device, theme);
                    },
                  ),
                ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                'Devices with access to this group can view and edit all expenses. '
                'Revoke access to remove a device.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(DeviceInfo device, ThemeData theme) {
    final isCurrentDevice = device.isCurrentDevice;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCurrentDevice
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            _getPlatformIcon(device.platform),
            color: isCurrentDevice
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(device.deviceName),
            ),
            if (isCurrentDevice)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'This device',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(device.platform),
            Text(
              'Added: ${_formatDate(device.addedAt)}',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              'Last active: ${_formatDate(device.lastActiveAt)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: !isCurrentDevice
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'rename') {
                    _renameDevice(device);
                  } else if (value == 'revoke') {
                    _revokeDevice(device);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'rename',
                    child: Text('Rename'),
                  ),
                  PopupMenuItem(
                    value: 'revoke',
                    child: Text(
                      'Revoke Access',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return Icons.android;
      case 'ios':
        return Icons.phone_iphone;
      case 'web':
        return Icons.web;
      case 'macos':
        return Icons.laptop_mac;
      case 'windows':
        return Icons.laptop_windows;
      case 'linux':
        return Icons.computer;
      default:
        return Icons.devices;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
