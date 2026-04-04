import 'package:in_app_review/in_app_review.dart';
import '../storage/preferences_service.dart';
import '../logging/logger_service.dart';
import '../../data/expense_group_storage_v2.dart';

/// Service to manage in-app store rating requests
///
/// Shows rating dialog:
/// - Once after user adds their 10th expense
/// - Then once per month (minimum 30 days gap)
class RatingService {
  static const int _initialExpenseThreshold = 10;
  static const int _monthlyThresholdDays = 30;

  static final InAppReview _inAppReview = InAppReview.instance;

  /// Check if we should prompt for rating and show dialog if appropriate
  ///
  /// Call this after successfully adding an expense.
  /// Returns true if rating prompt was shown.
  static Future<bool> checkAndPromptForRating() async {
    try {
      // Check if in-app review is available on this platform
      final isAvailable = await _inAppReview.isAvailable();
      if (!isAvailable) {
        LoggerService.info(
          'In-app review not available on this platform',
          name: 'rating',
        );
        return false;
      }

      // Get current expense count from all groups
      final allGroups = await ExpenseGroupStorageV2.getAllGroups();
      final totalExpenses = allGroups.fold<int>(
        0,
        (sum, group) => sum + group.expenses.length,
      );

      // Update the stored expense count
      final prefs = PreferencesService.instance;
      await prefs.storeRating.setTotalExpenseCount(totalExpenses);

      // Check if we should show the rating prompt
      final shouldShow = await _shouldShowRatingPrompt(totalExpenses);

      if (shouldShow) {
        LoggerService.info(
          'Showing rating prompt at $totalExpenses expenses',
          name: 'rating',
        );

        // Request the review
        await _inAppReview.requestReview();

        // Update tracking
        await prefs.storeRating.setLastPromptTime(DateTime.now());
        await prefs.storeRating.setHasShownInitialPrompt(true);

        return true;
      }

      return false;
    } catch (e) {
      LoggerService.warning(
        'Error checking/prompting for rating: $e',
        name: 'rating',
      );
      return false;
    }
  }

  /// Determine if we should show the rating prompt
  static Future<bool> _shouldShowRatingPrompt(int totalExpenses) async {
    // Need at least the threshold number of expenses
    if (totalExpenses < _initialExpenseThreshold) {
      return false;
    }

    final prefs = PreferencesService.instance;
    final hasShownInitial = prefs.storeRating.hasShownInitialPrompt();

    // If we haven't shown initial rating and user has 10+ expenses, show it
    if (!hasShownInitial && totalExpenses >= _initialExpenseThreshold) {
      return true;
    }

    // If we've already shown initial rating, check monthly throttle
    if (hasShownInitial) {
      final lastPrompt = prefs.storeRating.getLastPromptTime();

      if (lastPrompt == null) {
        // Shouldn't happen, but if it does, show the prompt
        return true;
      }

      final daysSinceLastPrompt = DateTime.now().difference(lastPrompt).inDays;

      // Show if it's been at least 30 days since last prompt
      if (daysSinceLastPrompt >= _monthlyThresholdDays) {
        return true;
      }
    }

    return false;
  }

  /// Manually trigger the rating prompt (for testing or user-initiated)
  ///
  /// This bypasses all checks and directly opens the store rating dialog.
  static Future<void> openStoreForRating() async {
    try {
      final isAvailable = await _inAppReview.isAvailable();

      if (isAvailable) {
        await _inAppReview.requestReview();
      } else {
        // Fallback: Open store listing
        await _inAppReview.openStoreListing();
      }
    } catch (e) {
      LoggerService.warning(
        'Error opening store for rating: $e',
        name: 'rating',
      );
    }
  }

  /// Reset rating state (useful for testing)
  static Future<void> resetRatingState() async {
    final prefs = PreferencesService.instance;
    await prefs.storeRating.setTotalExpenseCount(0);
    await prefs.storeRating.setHasShownInitialPrompt(false);
    await prefs.storeRating.clearLastPromptTime();
  }
}
