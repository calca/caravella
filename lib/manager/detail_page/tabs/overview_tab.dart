import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../data/expense_group.dart';
import '../../../widgets/currency_display.dart';

class OverviewTab extends StatelessWidget {
  final ExpenseGroup trip;
  const OverviewTab({super.key, required this.trip});

  /// Calcola i pareggi semplificati tra i partecipanti
  List<Map<String, dynamic>> _calculateSettlements(ExpenseGroup trip) {
    if (trip.participants.length < 2 || trip.expenses.isEmpty) {
      return [];
    }

    // Calcola il bilancio di ogni partecipante
    final Map<String, double> balances = {};
    final totalExpenses =
        trip.expenses.fold(0.0, (sum, e) => sum + (e.amount ?? 0));
    final fairShare = totalExpenses / trip.participants.length;

    // Inizializza i bilanci
    for (final participant in trip.participants) {
      balances[participant.name] = 0.0;
    }

    // Calcola quanto ha pagato ogni partecipante
    for (final expense in trip.expenses) {
      if (expense.amount != null) {
        balances[expense.paidBy] =
            (balances[expense.paidBy] ?? 0) + expense.amount!;
      }
    }

    // Sottrai la quota equa per ottenere il bilancio netto
    for (final participant in trip.participants) {
      balances[participant.name] =
          (balances[participant.name] ?? 0) - fairShare;
    }

    // Separa creditori e debitori
    final List<MapEntry<String, double>> creditors = [];
    final List<MapEntry<String, double>> debtors = [];

    balances.forEach((participant, balance) {
      if (balance > 0.01) {
        // Tolleranza per errori di arrotondamento
        creditors.add(MapEntry(participant, balance));
      } else if (balance < -0.01) {
        debtors
            .add(MapEntry(participant, -balance)); // Rendi positivo il debito
      }
    });

    // Ordina per importo decrescente per ottimizzare
    creditors.sort((a, b) => b.value.compareTo(a.value));
    debtors.sort((a, b) => b.value.compareTo(a.value));

    // Calcola i pareggi minimi
    final List<Map<String, dynamic>> settlements = [];

    // Copia le liste per non modificare quelle originali
    final List<MapEntry<String, double>> remainingCreditors =
        List.from(creditors);
    final List<MapEntry<String, double>> remainingDebtors = List.from(debtors);

    int creditorIndex = 0;
    int debtorIndex = 0;

    while (creditorIndex < remainingCreditors.length &&
        debtorIndex < remainingDebtors.length) {
      final creditor = remainingCreditors[creditorIndex];
      final debtor = remainingDebtors[debtorIndex];

      final settlement =
          creditor.value < debtor.value ? creditor.value : debtor.value;

      settlements.add({
        'from': debtor.key,
        'to': creditor.key,
        'amount': settlement,
      });

      // Aggiorna i bilanci
      remainingCreditors[creditorIndex] =
          MapEntry(creditor.key, creditor.value - settlement);
      remainingDebtors[debtorIndex] =
          MapEntry(debtor.key, debtor.value - settlement);

      // Passa al prossimo se completamente pareggiato
      if (remainingCreditors[creditorIndex].value < 0.01) creditorIndex++;
      if (remainingDebtors[debtorIndex].value < 0.01) debtorIndex++;
    }

    return settlements;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations(Localizations.localeOf(context).languageCode);
    final settlements = _calculateSettlements(trip);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListView(
        children: [
          const SizedBox(height: 8),

          // Sezione partecipanti
          Text(
            loc.get('expenses_by_participant'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ...trip.participants.map((p) {
            final total = trip.expenses
                .where((e) => e.paidBy == p.name)
                .fold<double>(0, (sum, e) => sum + (e.amount ?? 0));
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.colorScheme.primary
                        .withAlpha((0.1 * 255).toInt()),
                    child: Icon(
                      Icons.person,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      p.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  CurrencyDisplay(
                    value: total,
                    currency: trip.currency,
                    valueFontSize: 14.0,
                    currencyFontSize: 12.0,
                    alignment: MainAxisAlignment.end,
                    showDecimals: true,
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // Sezione Pareggia
          Text(
            loc.get('settlement'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          if (settlements.isEmpty)
            // Messaggio se tutto è a posto
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      loc.get('all_balanced'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            // Lista dei pareggi
            ...settlements.map((settlement) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    // Avatar con icona freccia
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: theme.colorScheme.error
                          .withAlpha((0.1 * 255).toInt()),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: settlement['from'],
                              style: TextStyle(
                                color: theme.colorScheme.error,
                              ),
                            ),
                            TextSpan(
                              text: ' deve dare a ',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            TextSpan(
                              text: settlement['to'],
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    CurrencyDisplay(
                      value: settlement['amount'],
                      currency: trip.currency,
                      valueFontSize: 14.0,
                      currencyFontSize: 12.0,
                      alignment: MainAxisAlignment.end,
                      showDecimals: true,
                      color: theme.colorScheme.error,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
