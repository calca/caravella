import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/main/caravella_app.dart';
import 'package:material_ui/material_ui.dart';
import 'package:zentoast/zentoast.dart';

void main() {
  testWidgets('dark theme: icons without a color of their own stay light', (
    tester,
  ) async {
    await tester.pumpWidget(
      ToastProvider.create(
        child: MaterialApp(
          theme: CaravellaThemes.dark,
          builder: (context, child) => AppFrame(child: child),
          home: Scaffold(
            body: Column(
              children: [
                const SearchBar(leading: Icon(Icons.search_outlined)),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final scheme = CaravellaThemes.dark.colorScheme;
    Color? colorOf(IconData icon) =>
        IconTheme.of(tester.element(find.byIcon(icon))).color;
    expect(colorOf(Icons.search_outlined), scheme.onSurface);
    expect(colorOf(Icons.close_rounded), isNot(const Color(0xDD000000)));
  });
}
