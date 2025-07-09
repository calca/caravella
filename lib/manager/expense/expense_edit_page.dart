import 'package:flutter/material.dart';
import '../../data/expense_details.dart';
import '../../data/expense_category.dart';
import '../../data/expense_group_storage.dart';
import '../../app_localizations.dart';
import 'expense_form_component.dart';
import '../details/tabs/expenses_action_result.dart';
import '../../widgets/caravella_app_bar.dart';
import '../../widgets/themed_outlined_button.dart';

class ExpenseEditPage extends StatefulWidget {
  final ExpenseDetails expense;
  final List<String> participants;
  final List<String> categories;
  final AppLocalizations loc;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final String? groupId; // ID del gruppo per salvare le nuove categorie

  const ExpenseEditPage({
    super.key,
    required this.expense,
    required this.participants,
    required this.categories,
    required this.loc,
    this.tripStartDate,
    this.tripEndDate,
    this.groupId,
  });

  @override
  State<ExpenseEditPage> createState() => _ExpenseEditPageState();
}

class _ExpenseEditPageState extends State<ExpenseEditPage> {
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.categories);
  }

  void _onSave(BuildContext context, ExpenseDetails updated) {
    Navigator.of(context).pop(ExpenseActionResult(updatedExpense: updated));
  }

  Future<void> _onCategoryAdded(String newCategory) async {
    // Aggiorna lo stato locale
    setState(() {
      if (!_categories.contains(newCategory)) {
        _categories.add(newCategory);
      }
    });

    // Salva nel storage se abbiamo l'ID del gruppo
    if (widget.groupId != null) {
      try {
        final groups = await ExpenseGroupStorage.getAllGroups();
        final groupIndex = groups.indexWhere((g) => g.id == widget.groupId);

        if (groupIndex != -1) {
          final existingCategories =
              groups[groupIndex].categories.map((c) => c.name).toList();
          if (!existingCategories.contains(newCategory)) {
            final updatedCategories = [...groups[groupIndex].categories];
            updatedCategories.add(ExpenseCategory(name: newCategory));
            groups[groupIndex] =
                groups[groupIndex].copyWith(categories: updatedCategories);
            await ExpenseGroupStorage.writeTrips(groups);
          }
        }
      } catch (e) {
        // Gestisci l'errore se necessario
        debugPrint('Error saving category: $e');
      }
    }
  }

  void _onDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.loc.get('delete_expense')),
        content: Text(widget.loc.get('delete_expense_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(widget.loc.get('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(widget.loc.get('delete')),
          ),
        ],
      ),
    );
    if (confirm == true) {
      if (!context.mounted) return; // Fix use_build_context_synchronously
      Navigator.of(context).pop(ExpenseActionResult(deleted: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CaravellaAppBar(
        actions: [
          ThemedOutlinedButton.icon(
            onPressed: () => _onDelete(context),
            icon:
                Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
            size: 40,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: ExpenseFormComponent(
          participants: widget.participants,
          categories: _categories, // Usa la lista locale aggiornabile
          initialExpense: widget.expense,
          onExpenseAdded: (updated) => _onSave(context, updated),
          onCategoryAdded: _onCategoryAdded, // Aggiungi il callback
          tripStartDate: widget.tripStartDate,
          tripEndDate: widget.tripEndDate,
          shouldAutoClose:
              false, // Non chiudere automaticamente perché è la ExpenseEditPage che gestisce la navigazione
        ),
      ),
    );
  }
}
