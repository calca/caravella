import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/expense_group_notifier.dart';
import '../data/expense_group_repository.dart';
import '../data/file_based_expense_group_repository.dart';
import '../data/category_service.dart';
import '../data/participant_service.dart';

/// Centralizes all provider configuration for the app.
/// This class manages the dependency injection setup for repositories,
/// services, and notifiers used throughout the application.
class AppProviders {
  /// Creates a MultiProvider with all necessary providers for the app.
  /// 
  /// The provider hierarchy is:
  /// 1. Repository provider (IExpenseGroupRepository)
  /// 2. Category service provider (depends on repository)
  /// 3. Participant service provider (depends on repository)
  /// 4. Expense group notifier (depends on both services)
  static MultiProvider create({required Widget child}) {
    return MultiProvider(
      providers: [
        // Repository provider
        Provider<IExpenseGroupRepository>(
          create: (_) => FileBasedExpenseGroupRepository(),
        ),
        // Category service provider
        ProxyProvider<IExpenseGroupRepository, CategoryService>(
          create: (context) => CategoryService(
            Provider.of<IExpenseGroupRepository>(context, listen: false),
          ),
          update: (context, repository, _) => CategoryService(repository),
        ),
        // Participant service provider
        ProxyProvider<IExpenseGroupRepository, ParticipantService>(
          create: (context) => ParticipantService(
            Provider.of<IExpenseGroupRepository>(context, listen: false),
          ),
          update: (context, repository, _) => ParticipantService(repository),
        ),
        // Expense group notifier with category and participant services
        ChangeNotifierProxyProvider2<CategoryService, ParticipantService, ExpenseGroupNotifier>(
          create: (context) => ExpenseGroupNotifier(
            categoryService: Provider.of<CategoryService>(context, listen: false),
            participantService: Provider.of<ParticipantService>(context, listen: false),
          ),
          update: (context, categoryService, participantService, previous) => previous ?? ExpenseGroupNotifier(
            categoryService: categoryService,
            participantService: participantService,
          ),
        ),
      ],
      child: child,
    );
  }
}