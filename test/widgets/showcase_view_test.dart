// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:thumbico/widgets/showcase_view.dart';

import '../widget_host.dart';

void main() {
  disableWindowingForTests();

  const leaveTooltip = 'Show the toolbar and status bar (F11, Esc)';

  /// The view in a box smaller than the screen, so the pointer can start outside it.
  Widget view({VoidCallback? onLeave}) {
    return host(
      Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: ShowcaseView(onLeave: onLeave ?? () {}, child: const Text('the image')),
        ),
      ),
    );
  }

  /// A mouse pointer resting outside the view.
  Future<TestGesture> mouseOutside(WidgetTester tester) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    return gesture;
  }

  double buttonOpacity(WidgetTester tester) =>
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;

  testWidgets('shows the child', (tester) async {
    await tester.pumpWidget(view());
    expect(find.text('the image'), findsOneWidget);
  });

  testWidgets('keeps the leave button hidden and inert while the pointer is elsewhere', (
    tester,
  ) async {
    var left = 0;
    await tester.pumpWidget(view(onLeave: () => left++));
    await mouseOutside(tester);

    expect(buttonOpacity(tester), 0);
    await tester.tap(find.byTooltip(leaveTooltip), warnIfMissed: false);
    expect(left, 0);
  });

  testWidgets('shows the leave button while the pointer is over the view, and it leaves', (
    tester,
  ) async {
    var left = 0;
    await tester.pumpWidget(view(onLeave: () => left++));
    final mouse = await mouseOutside(tester);

    await mouse.moveTo(tester.getCenter(find.byType(ShowcaseView)));
    await tester.pumpAndSettle();
    expect(buttonOpacity(tester), 1);

    await tester.tap(find.byTooltip(leaveTooltip));
    expect(left, 1);
  });

  testWidgets('hides the leave button again when the pointer leaves the view', (tester) async {
    await tester.pumpWidget(view());
    final mouse = await mouseOutside(tester);
    await mouse.moveTo(tester.getCenter(find.byType(ShowcaseView)));
    await tester.pumpAndSettle();

    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();

    expect(buttonOpacity(tester), 0);
  });

  testWidgets('puts the leave button in the top right corner', (tester) async {
    await tester.pumpWidget(view());
    final mouse = await mouseOutside(tester);
    await mouse.moveTo(tester.getCenter(find.byType(ShowcaseView)));
    await tester.pumpAndSettle();

    final viewRect = tester.getRect(find.byType(ShowcaseView));
    final button = tester.getRect(find.byTooltip(leaveTooltip));
    expect(button.top, greaterThanOrEqualTo(viewRect.top));
    expect(button.right, lessThanOrEqualTo(viewRect.right));
    expect(button.center.dx, greaterThan(viewRect.center.dx));
    expect(button.center.dy, lessThan(viewRect.center.dy));
  });
}
