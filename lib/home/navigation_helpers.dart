import 'package:flutter/material.dart';
import '../../manager/group/pages/group_creation_wizard_page.dart';

/// Centralized navigation helpers for the home module.
///
/// This class provides static methods for common navigation patterns
/// to ensure consistency across the app.
class NavigationHelpers {
  NavigationHelpers._();

  /// Navigates to the group creation wizard and returns the result.
  ///
  /// The result will be:
  /// - `String` (group ID) if a group was created successfully
  /// - `null` if the user cancelled or dismissed the wizard
  ///
  /// Optionally calls [onGroupCreated] callback with the group ID if provided.
  static Future<String?> openGroupCreation(
    BuildContext context, {
    VoidCallback? onGroupCreated,
  }) async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(builder: (context) => const GroupCreationWizardPage()),
    );

    if (result != null && result is String) {
      onGroupCreated?.call();
      return result;
    }

    return null;
  }

  /// Navigates to the group creation wizard and triggers a callback with the group ID.
  ///
  /// This is a convenience method for widgets that need both the group ID
  /// and a general "group added" callback.
  static Future<void> openGroupCreationWithCallback(
    BuildContext context, {
    required void Function([String? groupId]) onGroupAdded,
  }) async {
    final groupId = await openGroupCreation(context);
    onGroupAdded(groupId);
  }
}
