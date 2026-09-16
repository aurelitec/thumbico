// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
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

  testWidgets('draws the image at the display scale when asked', (tester) async {
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    final image = await solidImage(200, 100);
    addTearDown(image.dispose);

    await tester.pumpWidget(host(ThumbicoCanvas(image: image, scaleToDisplay: true)));

    expect(tester.getSize(find.byType(RawImage)), const Size(200, 100));
  });

  /// A wheel notch over the canvas, up when [up], with the pointer where the image is.
  Future<void> wheel(WidgetTester tester, {required bool up}) async {
    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: tester.getCenter(find.byType(ThumbicoCanvas)),
        scrollDelta: Offset(0, up ? -50 : 50),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Ctrl and the wheel over the image step the size instead of scrolling', (
    tester,
  ) async {
    final image = await solidImage(2000, 2000);
    addTearDown(image.dispose);
    final steps = <bool>[];
    await tester.pumpWidget(host(ThumbicoCanvas(image: image, onWheelStep: steps.add)));

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await wheel(tester, up: true);
    await wheel(tester, up: false);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

    expect(steps, [true, false]);
    for (final scrollable in tester.stateList<ScrollableState>(find.byType(Scrollable))) {
      expect(scrollable.position.pixels, 0, reason: 'a step must not scroll');
    }
  });

  testWidgets('the wheel without Ctrl scrolls and does not step', (tester) async {
    final image = await solidImage(2000, 2000);
    addTearDown(image.dispose);
    final steps = <bool>[];
    await tester.pumpWidget(host(ThumbicoCanvas(image: image, onWheelStep: steps.add)));

    await wheel(tester, up: false);

    expect(steps, isEmpty);
    final vertical = tester
        .stateList<ScrollableState>(find.byType(Scrollable))
        .map((state) => state.position.pixels);
    expect(vertical, contains(greaterThan(0)));
  });
}
