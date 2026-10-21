import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:io_caravella_egm/manager/group/pages/image_crop_page.dart';

/// The group photo is saved cropped to the chosen part and at most 1600 px
/// on its long side.
void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('crop_test'));
  tearDown(() => dir.deleteSync(recursive: true));

  File photo(int w, int h) {
    final image = img.Image(width: w, height: h);
    // Left half red, right half blue: tells which part was kept.
    img.fillRect(
      image,
      x1: 0,
      y1: 0,
      x2: w ~/ 2,
      y2: h,
      color: img.ColorRgb8(255, 0, 0),
    );
    img.fillRect(
      image,
      x1: w ~/ 2,
      y1: 0,
      x2: w,
      y2: h,
      color: img.ColorRgb8(0, 0, 255),
    );
    final f = File('${dir.path}/photo.jpg')
      ..writeAsBytesSync(img.encodeJpg(image));
    return f;
  }

  test('a camera photo is cropped and scaled down to 1600 px', () async {
    final f = photo(4000, 3000);
    final jpg = await cropAndResize(
      CropRequest(
        path: f.path,
        rect: const Rect.fromLTWH(2100, 500, 1800, 1200),
        maxSide: 1600,
      ),
    );
    final out = img.decodeJpg(jpg)!;
    expect(out.width, 1600);
    expect(out.height, closeTo(1067, 1));
    // Only the blue (right) half was inside the crop.
    final p = out.getPixel(800, 500);
    expect(p.b, greaterThan(200));
    expect(p.r, lessThan(60));
  });

  test('a small photo keeps its size', () async {
    final f = photo(600, 400);
    final jpg = await cropAndResize(
      CropRequest(
        path: f.path,
        rect: const Rect.fromLTWH(0, 0, 600, 400),
        maxSide: 1600,
      ),
    );
    final out = img.decodeJpg(jpg)!;
    expect(out.width, 600);
    expect(out.height, 400);
  });

  test('a crop past the edge stays inside the photo', () async {
    final f = photo(900, 600);
    final jpg = await cropAndResize(
      CropRequest(
        path: f.path,
        rect: const Rect.fromLTWH(600, 300, 600, 400),
        maxSide: 1600,
      ),
    );
    final out = img.decodeJpg(jpg)!;
    expect(out.width, 300);
    expect(out.height, 300);
  });
}
