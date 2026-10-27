import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/manager/expense/widgets/attachments/attachment_row.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late Directory dir;
  late File pdf;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('attachment_row');
    pdf = File('${dir.path}/1793101035787_Ricevuta_hotel.pdf')
      ..writeAsBytesSync(List.filled(2048, 0));
  });

  tearDown(() => dir.deleteSync(recursive: true));

  Future<void> pump(WidgetTester tester, {VoidCallback? onRemove}) =>
      tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: gen.AppLocalizations.localizationsDelegates,
          supportedLocales: gen.AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AttachmentRow(
              filePath: pdf.path,
              onTap: () {},
              onRemove: onRemove,
            ),
          ),
        ),
      );

  testWidgets('shows name, type and size, with a monochrome icon', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('Ricevuta_hotel.pdf'), findsOneWidget);
    expect(find.text('PDF · 2 kB'), findsOneWidget);
    expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    expect(find.byIcon(Icons.picture_as_pdf), findsNothing);
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('remove button is labelled and 48 dp', (tester) async {
    var removed = false;
    await pump(tester, onRemove: () => removed = true);
    final button = find.byTooltip('Remove Ricevuta_hotel.pdf');
    expect(button, findsOneWidget);
    final handle = tester.ensureSemantics();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
    await tester.tap(button);
    expect(removed, isTrue);
  });
}
