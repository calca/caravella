import 'dart:io';
import 'dart:ui' as ui;

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final brightness in Brightness.values) {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: brightness,
    );
    final palette = ExpenseGroupColorPalette.getPaletteColors(scheme);

    test('B text reads on every tint, ${brightness.name} (WCAG AA)', () {
      for (final color in [...palette, null]) {
        final look = GroupLook.of(color, brightness);
        expect(
          GroupLook.contrast(look.onTint, look.tint),
          greaterThanOrEqualTo(4.5),
          reason: 'color $color',
        );
      }
    });

    test('chip text reads on its pill over any tint or photo, '
        '${brightness.name}', () {
      final fg = TypeChip.foreground(brightness);
      final pill = TypeChip.background(brightness);
      for (final under in [
        for (final color in [...palette, null])
          GroupLook.of(color, brightness).tint,
        Colors.black,
        Colors.white,
      ]) {
        final over = Color.alphaBlend(pill, under);
        expect(
          GroupLook.contrast(fg, over),
          greaterThanOrEqualTo(4.5),
          reason: 'cover $under',
        );
      }
    });
  }

  test('the palette tints match the reviewed design', () {
    // Sky, light: #D3E9F6 on the canvas.
    final sky = GroupLook.of(const Color(0xFFAED6EE), Brightness.light).tint;
    expect((sky.r * 255).round(), closeTo(0xD3, 3));
    expect((sky.g * 255).round(), closeTo(0xE9, 3));
    expect((sky.b * 255).round(), closeTo(0xF6, 3));
  });

  test('photo tone: dark with white text, light only in the light theme', () {
    const snow = Color(0xFFDDE3EA);
    const fjord = Color(0xFF3A5468);
    final lightSnow = PhotoTone.fromAverage(snow, Brightness.light);
    expect(lightSnow.onTone, const Color(0xFF1B1B1B));
    expect(
      GroupLook.contrast(lightSnow.onTone, lightSnow.tone),
      greaterThan(7),
    );
    final darkSnow = PhotoTone.fromAverage(snow, Brightness.dark);
    expect(darkSnow.onTone, Colors.white);
    expect(GroupLook.contrast(darkSnow.onTone, darkSnow.tone), greaterThan(7));
    final lightFjord = PhotoTone.fromAverage(fjord, Brightness.light);
    expect(lightFjord.onTone, Colors.white);
  });

  testWidgets('photo tone loads from a file: a light photo gets a light band', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawRect(
        const Rect.fromLTWH(0, 0, 40, 30),
        Paint()..color = const Color(0xFFE2E6EC),
      );
      final image = await recorder.endRecording().toImage(40, 30);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = await Directory.systemTemp.createTemp('tone');
      final file = File('${dir.path}/snow.png');
      await file.writeAsBytes(png!.buffer.asUint8List());
      final tone = await PhotoTone.load(
        file.path,
        Brightness.light,
      ).timeout(const Duration(seconds: 10));
      expect(tone, isNotNull);
      expect(tone!.onTone, const Color(0xFF1B1B1B));
      expect(
        PhotoTone.cached(file.path, Brightness.dark)?.onTone,
        Colors.white,
      );
      await dir.delete(recursive: true);
    });
  });

  test('startup forgets the tones of photos no group uses', () async {
    Map<String, int>? stored;
    PhotoTone.onChanged = (all) => stored = all;
    addTearDown(() => PhotoTone.onChanged = null);
    PhotoTone.seed({'/gone/old.jpg@1': 0xFF102030});
    await PhotoTone.warmUp(const []);
    expect(stored, isEmpty);
  });
}
