import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../pages/auth_page.dart';

/// Helper class for authentication guards
class AuthGuard {
  static final _authService = AuthService();

  /// Check if user is authenticated and navigate to auth page if not
  /// Returns true if authenticated, false otherwise
  static Future<bool> requireAuth(BuildContext context) async {
    // Check if Supabase is configured
    if (!_authService.isConfigured) {
      // Supabase not configured, allow access (for backwards compatibility)
      return true;
    }

    // Check if user is authenticated
    if (_authService.isAuthenticated) {
      return true;
    }

    // User not authenticated, show auth page
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (ctx) => const AuthPage(),
        fullscreenDialog: true,
      ),
    );

    // Return true if user successfully authenticated
    return result == true && _authService.isAuthenticated;
  }

  /// Wrap a navigation action with authentication check
  /// Usage: AuthGuard.withAuth(context, () => Navigator.push(...))
  static Future<T?> withAuth<T>(
    BuildContext context,
    Future<T?> Function() action,
  ) async {
    final isAuthenticated = await requireAuth(context);
    if (!isAuthenticated) {
      return null;
    }
    return await action();
  }

  /// Show auth page and return authentication result
  static Future<bool> showAuthPage(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (ctx) => const AuthPage(),
        fullscreenDialog: true,
      ),
    );
    return result == true && _authService.isAuthenticated;
  }
}
