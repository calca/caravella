import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/manager/details/widgets/export_options_sheet.dart';
import 'package:io_caravella_egm/manager/group/widgets/editable_name_list.dart';
import 'package:material_ui/material_ui.dart';

/// What used to be a toast after tapping now shows before: a person who
/// paid an expense has a greyed-out bin that explains itself, and an
/// empty group's export formats say there's nothing to export (#618).
void main() {
  Widget app(Widget child) => MaterialApp(
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );

  testWidgets('a blocked delete explains itself under the row', (tester) async {
    final deleted = <int>[];
    await tester.pumpWidget(
      app(
        EditableNameList(
          title: 'People',
          items: const ['Anna', 'Marco'],
          addLabel: 'Add',
          hintLabel: 'Name',
          editTooltip: 'Edit',
          deleteTooltip: 'Delete',
          saveTooltip: 'Save',
          cancelTooltip: 'Cancel',
          addTooltip: 'Add',
          duplicateError: 'Taken',
          onAdd: (_) {},
          onEdit: (_, _) {},
          onDelete: deleted.add,
          deleteBlockedReason: (i) => i == 0 ? 'Paid for 2 expenses' : null,
        ),
      ),
    );
    expect(find.text('Paid for 2 expenses'), findsNothing);

    await tester.tap(find.byTooltip('Delete: Paid for 2 expenses'));
    await tester.pump();
    expect(find.text('Paid for 2 expenses'), findsOneWidget);
    expect(deleted, isEmpty);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pump();
    expect(deleted, [1]);
  });

  testWidgets('no expenses: the formats say so and their buttons are off', (
    tester,
  ) async {
    var taps = 0;
    void tap() => taps++;
    await tester.pumpWidget(
      app(
        ExportOptionsSheet(
          empty: true,
          onDownloadCsv: tap,
          onShareCsv: tap,
          onDownloadOfx: tap,
          onShareOfx: tap,
          onDownloadMarkdown: tap,
          onShareMarkdown: tap,
        ),
      ),
    );
    expect(find.text('No expenses to export'), findsNWidgets(3));
    for (final b in tester.widgetList<IconButton>(find.byType(IconButton))) {
      expect(b.onPressed, isNull);
    }
    expect(taps, 0);
  });
}
