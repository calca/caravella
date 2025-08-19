import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../data/expense_group.dart';
import '../../../widgets/currency_display.dart';
import '../../../state/locale_notifier.dart';
import 'widgets/daily_expenses_chart.dart';
import 'widgets/categories_pie_chart.dart';

class UnifiedOverviewTab extends StatelessWidget {
  final ExpenseGroup trip;
  const UnifiedOverviewTab({super.key, required this.trip});

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
        balances[expense.paidBy.name] =
            (balances[expense.paidBy.name] ?? 0) + expense.amount!;
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

  /// Calcola le statistiche giornaliere per il grafico
  Map<DateTime, double> _calculateDailyStats() {
    final stats = <DateTime, double>{};

    // Se non ci sono date definite, usa il mese corrente
    if (trip.startDate == null || trip.endDate == null) {
      final now = DateTime.now();
      final firstDay = DateTime(now.year, now.month, 1);
      final lastDay = DateTime(now.year, now.month + 1, 0);

      DateTime currentDate = firstDay;
      while (currentDate.isBefore(lastDay) ||
          currentDate.isAtSameMomentAs(lastDay)) {
        stats[currentDate] = 0.0;
        currentDate = currentDate.add(const Duration(days: 1));
      }

      for (final expense in trip.expenses) {
        final date =
            DateTime(expense.date.year, expense.date.month, expense.date.day);
        // Solo spese del mese corrente
        if (date.month == now.month && date.year == now.year) {
          stats[date] = (stats[date] ?? 0.0) + (expense.amount ?? 0.0);
        }
      }
      return stats;
    }

    // Inizializza tutti i giorni del viaggio con 0
    DateTime currentDate = DateTime(
        trip.startDate!.year, trip.startDate!.month, trip.startDate!.day);
    final endDate =
        DateTime(trip.endDate!.year, trip.endDate!.month, trip.endDate!.day);

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      stats[currentDate] = 0.0;
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Aggiungi le spese reali
    for (final expense in trip.expenses) {
      if (expense.amount != null) {
        final expenseDate =
            DateTime(expense.date.year, expense.date.month, expense.date.day);
        stats[expenseDate] = (stats[expenseDate] ?? 0.0) + expense.amount!;
      }
    }

    return stats;
  }

  /// Aggrega le spese per settimana (lunedì-domenica)
  Map<DateTime, double> _calculateWeeklyStats() {
    final dailyStats = _calculateDailyStats();
    final weeklyStats = <DateTime, double>{};
    if (dailyStats.isEmpty) return weeklyStats;

    // Trova il primo giorno (lunedì) e l'ultimo giorno
    final sortedDays = dailyStats.keys.toList()..sort();
    DateTime firstDay = sortedDays.first;
    DateTime lastDay = sortedDays.last;

    // Allinea il primo giorno a lunedì
    firstDay = firstDay.subtract(Duration(days: firstDay.weekday - 1));

    DateTime currentWeekStart = firstDay;
    while (currentWeekStart.isBefore(lastDay) ||
        currentWeekStart.isAtSameMomentAs(lastDay)) {
      double weekTotal = 0.0;
      for (int i = 0; i < 7; i++) {
        final day = currentWeekStart.add(Duration(days: i));
        weekTotal += dailyStats[day] ?? 0.0;
      }
      weeklyStats[currentWeekStart] = weekTotal;
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
    }
    return weeklyStats;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations(LocaleNotifier.of(context)?.locale ?? 'it');
    final settlements = _calculateSettlements(trip);

    if (trip.expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard_customize_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              loc.get('no_expenses_for_statistics'),
              style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    // Calcola le statistiche per i grafici
    final weeklyStats = _calculateWeeklyStats();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grafici (massimo 2 come richiesto)
          if (weeklyStats.isNotEmpty) ...[
            DailyExpensesChart(
              trip: trip,
              dailyStats: weeklyStats,
              loc: loc,
            ),
            const SizedBox(height: 24),
          ],
          
          CategoriesPieChart(
            trip: trip,
            loc: loc,
          ),
          
          const SizedBox(height: 32),

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
                .where((e) => e.paidBy.name == p.name)
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