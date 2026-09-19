// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:thumbico/widgets/two_axis_scroll_view.dart';

import '../widget_host.dart';

void main() {
  disableWindowingForTests();

  /// The view around a box of the given size.
  Widget viewOf(double width, double height) => host(
    TwoAxisScrollView(
      child: SizedBox(key: const Key('child'), width: width, height: height),
    ),
  );

  testWidgets('centres a child that fits', (tester) async {
    await tester.pumpWidget(viewOf(100, 100));

    final view = tester.getRect(find.byType(TwoAxisScrollView));
    expect(tester.getRect(find.byKey(const Key('child'))).center, view.center);
  });

  testWidgets('both scroll bars lie along the view\'s edges, however large the child', (
    tester,
  ) async {
    await tester.pumpWidget(viewOf(5000, 5000));

    final view = tester.getRect(find.byType(TwoAxisScrollView));
    final bars = find.descendant(
      of: find.byType(TwoAxisScrollView),
      matching: find.byType(Scrollbar),
    );
    expect(bars, findsNWidgets(2), reason: 'ours only, none added by the platform');
    for (final bar in bars.evaluate()) {
      expect(tester.getRect(find.byWidget(bar.widget)), view);
    }
  });

  testWidgets('the scroll bars do not fade', (tester) async {
    await tester.pumpWidget(viewOf(5000, 5000));

    for (final bar in tester.widgetList<Scrollbar>(find.byType(Scrollbar))) {
      expect(bar.thumbVisibility, isTrue);
    }
  });

  testWidgets('each scroll bar follows its own axis', (tester) async {
    await tester.pumpWidget(viewOf(5000, 5000));

    final axes = tester
        .widgetList<Scrollbar>(find.byType(Scrollbar))
        .map((bar) => bar.controller!.position.axis)
        .toSet();
    expect(axes, {Axis.horizontal, Axis.vertical});
  });
}
