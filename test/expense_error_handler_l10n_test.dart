import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/manager/expense/errors/expense_error_handler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:zentoast/zentoast.dart';

/// The expense errors speak the app's language (they were English-only)
/// and keep technical details out of the message.
void main() {
  Future<void> show(
    WidgetTester tester,
    void Function(BuildContext) action,
  ) async {
    await tester.pumpWidget(
      ToastProvider.create(
        child: MaterialApp(
          locale: const Locale('it'),
          localizationsDelegates: const [
            gen.AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: gen.AppLocalizations.supportedLocales,
          // As in the app: toasts show in a ToastViewer above the page.
          builder: (context, child) => Stack(
            children: [
              ?child,
              const ToastViewer(alignment: Alignment.bottomCenter),
            ],
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => action(context),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('attachment limit in Italian', (tester) async {
    await show(
      tester,
      (c) => ExpenseErrorHandler.showAttachmentLimitError(c, maxCount: 5),
    );
    expect(find.text('Puoi aggiungere al massimo 5 allegati'), findsOneWidget);
  });

  testWidgets('a failed attachment hides the exception', (tester) async {
    await show(
      tester,
      (c) => ExpenseErrorHandler.showAttachmentAddError(
        c,
        Exception('PlatformException(io_error)'),
      ),
    );
    expect(find.text('Impossibile aggiungere l’allegato'), findsOneWidget);
    expect(find.textContaining('PlatformException'), findsNothing);
  });
}
