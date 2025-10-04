import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/logger_service.dart';
import 'supabase_client_service.dart';

/// Service for managing user authentication via Supabase
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _supabaseClient = SupabaseClientService();

  /// Check if user is currently authenticated
  bool get isAuthenticated {
    if (!_supabaseClient.isInitialized) return false;
    return _supabaseClient.client?.auth.currentUser != null;
  }

  /// Get current user
  User? get currentUser {
    if (!_supabaseClient.isInitialized) return null;
    return _supabaseClient.client?.auth.currentUser;
  }

  /// Get current user ID
  String? get currentUserId {
    return currentUser?.id;
  }

  /// Sign in with email and password
  Future<AuthResponse?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (!_supabaseClient.isInitialized) {
        LoggerService.error('Supabase not initialized');
        return null;
      }

      LoggerService.info('Attempting to sign in user: $email');
      
      final response = await _supabaseClient.client!.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        LoggerService.info('User signed in successfully: ${response.user!.id}');
      }

      return response;
    } catch (e) {
      LoggerService.error('Failed to sign in: $e');
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<AuthResponse?> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (!_supabaseClient.isInitialized) {
        LoggerService.error('Supabase not initialized');
        return null;
      }

      LoggerService.info('Attempting to sign up user: $email');

      final response = await _supabaseClient.client!.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );

      if (response.user != null) {
        LoggerService.info('User signed up successfully: ${response.user!.id}');
      }

      return response;
    } catch (e) {
      LoggerService.error('Failed to sign up: $e');
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      if (!_supabaseClient.isInitialized) {
        LoggerService.warning('Supabase not initialized');
        return;
      }

      LoggerService.info('Signing out user');
      await _supabaseClient.client!.auth.signOut();
      LoggerService.info('User signed out successfully');
    } catch (e) {
      LoggerService.error('Failed to sign out: $e');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      if (!_supabaseClient.isInitialized) {
        LoggerService.error('Supabase not initialized');
        return;
      }

      LoggerService.info('Sending password reset email to: $email');
      await _supabaseClient.client!.auth.resetPasswordForEmail(email);
      LoggerService.info('Password reset email sent');
    } catch (e) {
      LoggerService.error('Failed to send reset email: $e');
      rethrow;
    }
  }

  /// Listen to authentication state changes
  Stream<AuthState> get authStateChanges {
    if (!_supabaseClient.isInitialized) {
      return Stream.empty();
    }
    return _supabaseClient.client!.auth.onAuthStateChange;
  }

  /// Update user metadata
  Future<UserResponse?> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (!_supabaseClient.isInitialized) {
        LoggerService.error('Supabase not initialized');
        return null;
      }

      LoggerService.info('Updating user');
      final response = await _supabaseClient.client!.auth.updateUser(
        UserAttributes(
          email: email,
          password: password,
          data: data,
        ),
      );

      LoggerService.info('User updated successfully');
      return response;
    } catch (e) {
      LoggerService.error('Failed to update user: $e');
      rethrow;
    }
  }

  /// Check if Supabase is configured for authentication
  bool get isConfigured => _supabaseClient.isInitialized;
}
