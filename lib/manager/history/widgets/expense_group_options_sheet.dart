import 'package:flutter/material.dart';
import '../../../data/expense_group.dart';
import '../../../data/expense_participant.dart';
import '../../../data/expense_category.dart';
import '../../../data/expense_group_storage.dart';
import '../../group/pages/add_new_expenses_group.dart';

class ExpenseGroupOptionsSheet extends StatelessWidget {
  final ExpenseGroup trip;
  final VoidCallback onTripDeleted;
  final VoidCallback onTripUpdated;

  const ExpenseGroupOptionsSheet({
    super.key,
    required this.trip,
    required this.onTripDeleted,
    required this.onTripUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    trip.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildOptionTile(
                    icon: Icons.edit_rounded,
                    title: 'Modifica gruppo',
                    subtitle: 'Modifica nome, date e partecipanti',
                    onTap: () => _handleEdit(context),
                    context: context,
                  ),
                  _buildOptionTile(
                    icon: Icons.copy_rounded,
                    title: 'Duplica gruppo',
                    subtitle: 'Crea una copia con gli stessi dati',
                    onTap: () => _handleDuplicate(context),
                    context: context,
                  ),
                  _buildOptionTile(
                    icon: Icons.delete_rounded,
                    title: 'Elimina gruppo',
                    subtitle: 'Rimuovi definitivamente questo gruppo',
                    onTap: () => _handleDelete(context),
                    context: context,
                    isDestructive: true,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required BuildContext context,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.05),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDestructive ? color : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleEdit(BuildContext context) async {
    Navigator.of(context).pop();
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExpensesGroupEditPage(trip: trip),
      ),
    );
    if (result == true) {
      onTripUpdated();
    }
  }

  void _handleDuplicate(BuildContext context) async {
    Navigator.of(context).pop();

    final newTrip = ExpenseGroup(
      title: "${trip.title} (Copia)",
      expenses: [],
      participants: trip.participants
          .map((p) => ExpenseParticipant(name: p.name))
          .toList(),
      startDate: trip.startDate,
      endDate: trip.endDate,
      currency: trip.currency,
      categories: trip.categories
          .map((c) => ExpenseCategory(name: c.name))
          .toList(),
    );

    final allTrips = await ExpenseGroupStorage.getAllGroups();
    allTrips.add(newTrip);
    await ExpenseGroupStorage.writeTrips(allTrips);

    onTripUpdated();
  }

  void _handleDelete(BuildContext context) async {
    Navigator.of(context).pop();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina viaggio'),
        content: Text('Vuoi davvero eliminare "${trip.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final allTrips = await ExpenseGroupStorage.getAllGroups();
      allTrips.removeWhere((t) => t.id == trip.id);
      await ExpenseGroupStorage.writeTrips(allTrips);
      onTripDeleted();
    }
  }
}
