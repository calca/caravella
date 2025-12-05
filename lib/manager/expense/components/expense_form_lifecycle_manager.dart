import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'expense_form_config.dart';
import '../state/expense_form_controller.dart';
import '../state/expense_form_state.dart';
import '../coordination/form_scroll_coordinator.dart';
import '../location/location_service.dart';

/// Manages lifecycle events for ExpenseFormComponent
///
/// Handles initialization, updates, and cleanup of form-related resources.
class ExpenseFormLifecycleManager with WidgetsBindingObserver {
  final ExpenseFormConfig config;
  final void Function(ExpenseFormController) onControllerReady;

  ExpenseFormController? _controller;
  FormScrollCoordinator? _scrollCoordinator;
  List<ExpenseCategory> _categories = [];
  bool _autoLocationEnabled = false;
  ExpenseLocation? _autoRetrievedLocation;
  bool _isRetrievingLocation = false;
  bool _isInitialized = false;

  ExpenseFormLifecycleManager({
    required this.config,
    required this.onControllerReady,
  });

  List<ExpenseCategory> get categories => _categories;
  bool get isRetrievingLocation => _isRetrievingLocation;
  ExpenseLocation? get autoRetrievedLocation => _autoRetrievedLocation;
  FormScrollCoordinator? get scrollCoordinator => _scrollCoordinator;

  /// Initialize all components
  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;

    _autoLocationEnabled = config.autoLocationEnabled;
    _categories = List.from(config.categories);

    // Initialize controller
    _controller = ExpenseFormController(
      initialState: _buildInitialState(),
      categories: _categories,
    );

    // Initialize scroll coordinator
    if (config.scrollController != null) {
      _scrollCoordinator = FormScrollCoordinator(
        scrollController: config.scrollController!,
        context: context,
      );
    }

    // Handle newly added category
    if (config.newlyAddedCategory != null) {
      await _handleNewlyAddedCategory();
    }

    // Auto-retrieve location if enabled
    if (_shouldAutoRetrieveLocation() && context.mounted) {
      await _retrieveAutoLocation(context);
    }

    // Notify ready
    onControllerReady(_controller!);

    // Finish initialization to enable state updates
    _controller!.finishInitialization();

    // Register observers
    WidgetsBinding.instance.addObserver(this);

    _isInitialized = true;
  }

  /// Handle widget updates
  void handleUpdate(ExpenseFormConfig oldConfig, ExpenseFormConfig newConfig) {
    // Update categories if changed
    if (oldConfig.categories != newConfig.categories) {
      _categories = List.from(newConfig.categories);
      // Controller will pick up new categories on next access
    }

    // Handle auto-location changes
    if (oldConfig.autoLocationEnabled != newConfig.autoLocationEnabled) {
      _autoLocationEnabled = newConfig.autoLocationEnabled;
    }
  }

  /// Update categories list
  void updateCategories(List<ExpenseCategory> categories) {
    _categories = categories;
    // Controller will pick up new categories on next access
  }

  /// Cleanup resources
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _scrollCoordinator = null;
    _isInitialized = false;
  }

  // Private helper methods

  ExpenseFormState _buildInitialState() {
    if (config.initialExpense != null) {
      return ExpenseFormState.fromExpense(
        config.initialExpense!,
        config.categories,
      );
    }
    return ExpenseFormState.initial(
      participants: config.participants,
      categories: config.categories,
    );
  }

  bool _shouldAutoRetrieveLocation() {
    return _autoLocationEnabled &&
        config.isCreateMode &&
        _controller?.state.location == null;
  }

  Future<void> _retrieveAutoLocation(BuildContext context) async {
    if (!context.mounted) return;

    _isRetrievingLocation = true;

    final location = await LocationService.getCurrentLocation(
      context,
      onStatusChanged: (retrieving) {
        _isRetrievingLocation = retrieving;
      },
    );

    if (location != null) {
      _autoRetrievedLocation = location;
      _controller?.updateLocation(location);
    }

    _isRetrievingLocation = false;
  }

  Future<void> _handleNewlyAddedCategory() async {
    final categoryToSelect = _categories.firstWhere(
      (c) => c.id == config.newlyAddedCategory,
      orElse: () => _categories.isNotEmpty
          ? _categories.first
          : ExpenseCategory(id: '', name: '', createdAt: DateTime.now()),
    );

    if (categoryToSelect.id.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 100));
      _controller?.updateCategory(categoryToSelect);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes if needed
  }
}
