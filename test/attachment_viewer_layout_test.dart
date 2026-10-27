import 'dart:io';

import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/manager/expense/pages/attachment_viewer_page.dart';
import 'package:material_ui/material_ui.dart';

/// The viewer's round buttons sit at the top of the screen, not over the
/// middle of the photo.
void main() {
  testWidgets('top bar is pinned to the top over a full-screen attachment', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final dir = Directory.systemTemp.createTempSync('viewer');
    addTearDown(() => dir.deleteSync(recursive: true));
    final a = File('${dir.path}/a.jpg')..writeAsBytesSync([0]);
    final b = File('${dir.path}/b.pdf')..writeAsBytesSync([0]);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          gen.AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: gen.AppLocalizations.supportedLocales,
        home: AttachmentViewerPage(
          attachments: [a.path, b.path],
          initialIndex: 0,
          onDelete: (_) {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // With a title (more than one attachment) the bar used to stretch to
    // the full height and center its buttons mid-screen.
    expect(find.text('1 / 2'), findsOneWidget);
    final back = tester.getRect(find.byTooltip('Back'));
    final bar = tester.getRect(find.byType(MediaTopBar));
    expect(back.top, lessThan(80));
    expect(bar.height, lessThan(120));
    // ...and the attachment still fills the screen under it.
    expect(tester.getSize(find.byType(PageView)), const Size(360, 800));
  });
}
