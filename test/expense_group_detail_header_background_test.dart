import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter/foundation.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/manager/details/pages/expense_group_detail_page.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:provider/provider.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _tempDir = Directory.systemTemp
      .createTempSync('detail_header_bg_test')
      .path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();

  setUpAll(() {
    ExpenseGroupRepositoryFactory.reset();
    ExpenseGroupRepositoryFactory.getRepository(useJsonBackend: true);
  });

  setUp(() {
    ExpenseGroupStorageV2.clearCache();
  });

  testWidgets(
    'ExpenseGroupDetailPage uses the home gradient when the group has a color',
    (tester) async {
      const groupColor = 0xFFE57373;
      final group = ExpenseGroup(
        id: 'detail-gradient-group',
        title: 'Color Group',
        expenses: const [],
        participants: [ExpenseParticipant(id: '1', name: 'Alice')],
        categories: [ExpenseCategory(id: '1', name: 'Food')],
        currency: 'EUR',
        color: groupColor,
      );

      await ExpenseGroupStorageV2.addExpenseGroup(group);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ExpenseGroupNotifier(),
          child: MaterialApp(
            localizationsDelegates: const [
              gen.AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('it'), Locale('en')],
            home: ExpenseGroupDetailPage(trip: group),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final context = tester.element(find.byType(ExpenseGroupDetailPage));
      final colorScheme = Theme.of(context).colorScheme;
      final expectedGradient = GroupBackgroundUtils.resolve(
        group,
        colorScheme,
        baseColor: colorScheme.surfaceContainer,
      ).gradient!;

      final gradientFinder = find.byWidgetPredicate((widget) {
        if (widget is! DecoratedBox) {
          return false;
        }
        final decoration = widget.decoration;
        if (decoration is! BoxDecoration) {
          return false;
        }
        final gradient = decoration.gradient;
        if (gradient is! LinearGradient) {
          return false;
        }

        return listEquals(gradient.colors, expectedGradient.colors) &&
            listEquals(gradient.stops, expectedGradient.stops) &&
            gradient.begin == expectedGradient.begin &&
            gradient.end == expectedGradient.end;
      });

      expect(gradientFinder, findsOneWidget);
    },
  );
}
