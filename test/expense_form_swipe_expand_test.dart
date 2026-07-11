import 'package:caravella_core/caravella_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/manager/expense/components/expense_form_component.dart';

void main() {
  const swipeUpOffset = Offset(0, -350);
  const swipeUpVelocity = 300.0;

  testWidgets('compact expense form expands via swipe up without expand button', (
    tester,
  ) async {
    ExpenseFormState? expandedState;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          gen.AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('it'), Locale('en')],
        home: Scaffold(
          body: ExpenseFormComponent.legacy(
            participants: const [
              ExpenseParticipant(id: 'p1', name: 'Mario'),
            ],
            categories: const [
              ExpenseCategory(id: 'c1', name: 'Food'),
            ],
            onExpenseAdded: (_) {},
            onCategoryAdded: (_) {},
            groupId: 'g1',
            autoLocationEnabled: false,
            fullEdit: false,
            onExpand: (state) => expandedState = state,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final l10n = gen.AppLocalizations.of(
      tester.element(find.byType(ExpenseFormComponent)),
    );
    expect(find.byTooltip(l10n.expand_form), findsNothing);

    await tester.fling(
      find.byType(ExpenseFormComponent),
      swipeUpOffset,
      swipeUpVelocity,
    );
    await tester.pumpAndSettle();

    expect(expandedState, isNotNull);
    expect(expandedState!.paidBy?.id, 'p1');
    expect(expandedState!.category?.id, 'c1');
    expect(expandedState!.isExpanded, isTrue);
  });
}
