// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:thumbico/common/theme.dart';
import 'package:thumbico/widgets/thumbico_canvas.dart';

import '../widget_host.dart';

/// A solid image of the given pixel size.
Future<ui.Image> solidImage(int width, int height) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    ui.Paint()..color = const ui.Color(0xFF3366CC),
  );
  return recorder.endRecording().toImage(width, height);
}

void main() {
  disableWindowingForTests();

  testWidgets('draws nothing without an image', (tester) async {
    await tester.pumpWidget(host(const ThumbicoCanvas()));
    expect(find.byType(RawImage), findsNothing);
  });

  testWidgets('lays the image out at one image pixel per device pixel', (tester) async {
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    final image = await solidImage(200, 100);
    addTearDown(image.dispose);

    await tester.pumpWidget(host(ThumbicoCanvas(image: image)));

    expect(tester.getSize(find.byType(RawImage)), const Size(100, 50));
  });

  testWidgets('centres an image that fits', (tester) async {
    final image = await solidImage(100, 100);
    addTearDown(image.dispose);

    await tester.pumpWidget(host(ThumbicoCanvas(image: image)));

    final canvas = tester.getRect(find.byType(ThumbicoCanvas));
    final drawn = tester.getRect(find.byType(RawImage));
    expect(drawn.center, canvas.center);
  });

  testWidgets('the checkerboard stops at the image edge when the size is not whole squares', (
    tester,
  ) async {
    final image = await solidImage(20, 12);
    addTearDown(image.dispose);
    await tester.pumpWidget(host(ThumbicoCanvas(image: image)));

    // The painter behind the image, the only one inside the canvas that has a child
    final painter = tester
        .widgetList<CustomPaint>(
          find.descendant(of: find.byType(ThumbicoCanvas), matching: find.byType(CustomPaint)),
        )
        .firstWhere((paint) => paint.child is RawImage)
        .painter!;

    // Painted alone for a 20 by 12 image onto a larger transparent sheet
    final pixels = await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      painter.paint(Canvas(recorder), const Size(20, 12));
      final sheet = await recorder.endRecording().toImage(32, 32);
      final data = await sheet.toByteData();
      sheet.dispose();
      return data!;
    });
    int alphaAt(int x, int y) => pixels!.getUint8((y * 32 + x) * 4 + 3);

    expect(alphaAt(18, 10), 255, reason: 'inside the image, in the last partial squares');
    expect(alphaAt(22, 5), 0, reason: 'right of the image');
    expect(alphaAt(5, 14), 0, reason: 'below the image');
  });

  for (final (brightness, first, second) in [
    (Brightness.light, const Color(0xFFFFFFFF), const Color(0xFFCCCCCC)),
    (Brightness.dark, const Color(0xFF2B2B2B), const Color(0xFF3A3A3A)),
  ]) {
    testWidgets('the checkerboard takes the ${brightness.name} theme\'s pair of greys', (
      tester,
    ) async {
      final image = await solidImage(32, 32);
      addTearDown(image.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme(brightness),
          home: Material(child: ThumbicoCanvas(image: image)),
        ),
      );
      final painter = tester
          .widgetList<CustomPaint>(
            find.descendant(of: find.byType(ThumbicoCanvas), matching: find.byType(CustomPaint)),
          )
          .firstWhere((paint) => paint.child is RawImage)
          .painter!;

      final pixels = await tester.runAsync(() async {
        final recorder = ui.PictureRecorder();
        painter.paint(Canvas(recorder), const Size(32, 32));
        final sheet = await recorder.endRecording().toImage(32, 32);
        final data = await sheet.toByteData();
        sheet.dispose();
        return data!;
      });
      Color colorAt(int x, int y) {
        final offset = (y * 32 + x) * 4;
        return Color.fromARGB(
          255,
          pixels!.getUint8(offset),
          pixels.getUint8(offset + 1),
          pixels.getUint8(offset + 2),
        );
      }

      // The first square, and the one beside it
      expect(colorAt(2, 2), first);
      expect(colorAt(10, 2), second);
    });
  }

  testWidgets('draws the image at the display scale when asked', (tester) async {
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    final image = await solidImage(200, 100);
    addTearDown(image.dispose);

    await tester.pumpWidget(host(ThumbicoCanvas(image: image, scaleToDisplay: true)));

    expect(tester.getSize(find.byType(RawImage)), const Size(200, 100));
  });
}
