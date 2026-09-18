// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:thumbico/widgets/size_field.dart';

import '../widget_host.dart';

void main() {
  disableWindowingForTests();

  late TextEditingController controller;

  setUp(() {
    controller = TextEditingController(text: '256 x 256');
    addTearDown(controller.dispose);
  });

  Widget field({
    VoidCallback? onSubmitted,
    VoidCallback? onBigger,
    VoidCallback? onSmaller,
    bool scaleToDisplay = false,
    ValueChanged<bool>? onScaleToDisplayChanged,
  }) {
    return host(
      SizeField(
        controller: controller,
        onSubmitted: onSubmitted ?? () {},
        onBigger: onBigger ?? () {},
        onSmaller: onSmaller ?? () {},
        scaleToDisplay: scaleToDisplay,
        onScaleToDisplayChanged: onScaleToDisplayChanged ?? (_) {},
      ),
    );
  }

  /// What one Enter press does on Windows: a key event, then the field's submit action.
  Future<void> pressEnter(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  Future<void> openFlyout(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Sizes'));
    await tester.pumpAndSettle();
  }

  final presets = find.byType(MenuItemButton);

  testWidgets('Enter after typing submits what was typed, once', (tester) async {
    var submits = 0;
    await tester.pumpWidget(field(onSubmitted: () => submits++));

    await tester.enterText(find.byType(TextField), '512');
    await pressEnter(tester);

    expect(submits, 1);
    expect(controller.text, '512');
  });

  testWidgets('nothing opens on a click in the field or on typing', (tester) async {
    await tester.pumpWidget(field());

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(presets, findsNothing);

    await tester.enterText(find.byType(TextField), '5');
    await tester.pumpAndSettle();
    expect(presets, findsNothing);
  });

  testWidgets('Left and Right move the caret inside the field', (tester) async {
    await tester.pumpWidget(field());
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    controller.selection = const TextSelection.collapsed(offset: 3);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(controller.selection, const TextSelection.collapsed(offset: 2));

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(controller.selection, const TextSelection.collapsed(offset: 3));
  });

  testWidgets('the chevron opens the flyout with the standard sizes in the one format', (
    tester,
  ) async {
    await tester.pumpWidget(field());
    expect(find.text('16 x 16'), findsNothing);

    await openFlyout(tester);

    expect(presets, findsNWidgets(SizeField.presets.length));
    expect(find.text('16 x 16'), findsOneWidget);
    expect(find.text('2048 x 2048'), findsOneWidget);
  });

  testWidgets('picking a standard size writes it to the field, submits, and closes', (
    tester,
  ) async {
    var submits = 0;
    await tester.pumpWidget(field(onSubmitted: () => submits++));

    await openFlyout(tester);
    await tester.tap(find.text('512 x 512'));
    await tester.pumpAndSettle();

    expect(controller.text, '512 x 512');
    expect(submits, 1);
    expect(presets, findsNothing, reason: 'the flyout closes on a pick');
  });

  testWidgets('Bigger and Smaller report a step and keep the flyout open', (tester) async {
    var bigger = 0;
    var smaller = 0;
    await tester.pumpWidget(field(onBigger: () => bigger++, onSmaller: () => smaller++));
    await openFlyout(tester);

    await tester.tap(find.byTooltip('Bigger x 1.25 (Ctrl++)'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Smaller / 1.25 (Ctrl+-)'));
    await tester.pumpAndSettle();

    expect(bigger, 1);
    expect(smaller, 1);
    expect(presets, findsNWidgets(SizeField.presets.length), reason: 'a step keeps it open');
  });

  testWidgets('the flyout hangs under the field and is as wide as it, as a combo box list is', (
    tester,
  ) async {
    // Placed as the toolbar places it, at its own width with room below
    await tester.pumpWidget(
      host(
        Align(
          alignment: .topCenter,
          child: SizeField(
            controller: controller,
            onSubmitted: () {},
            onBigger: () {},
            onSmaller: () {},
            scaleToDisplay: false,
            onScaleToDisplayChanged: (_) {},
          ),
        ),
      ),
    );
    await openFlyout(tester);

    final card = find
        .ancestor(of: find.text('512 x 512'), matching: find.byType(Material))
        .evaluate()
        .map((element) => element.widget as Material)
        .firstWhere((material) => material.elevation > 0);
    final cardBox = tester.getRect(find.byWidget(card));
    final fieldBox = tester.getRect(find.byType(TextField));

    expect(cardBox.left, fieldBox.left);
    expect(cardBox.width, fieldBox.width);
    expect(cardBox.top, fieldBox.bottom);
  });

  testWidgets('the step tooltips name the factor the steps use', (tester) async {
    await tester.pumpWidget(field());
    await openFlyout(tester);

    final factor = SizeField.stepFactor.toString();
    expect(find.byTooltip('Bigger x $factor (Ctrl++)'), findsOneWidget);
    expect(find.byTooltip('Smaller / $factor (Ctrl+-)'), findsOneWidget);
  });

  testWidgets('the display-scale toggle shows the current state and reports the other', (
    tester,
  ) async {
    bool? chosen;
    await tester.pumpWidget(field(onScaleToDisplayChanged: (value) => chosen = value));
    await openFlyout(tester);

    final toggle = find.byTooltip('Display scale instead of real pixels');
    IconButton button() =>
        tester.widget<IconButton>(find.ancestor(of: toggle, matching: find.byType(IconButton)));
    expect(button().isSelected, isFalse);

    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(chosen, isTrue);
    expect(presets, findsNWidgets(SizeField.presets.length), reason: 'a toggle keeps it open');
  });

  testWidgets('the display-scale toggle is filled while the display scale is on', (
    tester,
  ) async {
    await tester.pumpWidget(field(scaleToDisplay: true));
    await openFlyout(tester);

    final toggle = find.byTooltip('Display scale instead of real pixels');
    final button = tester.widget<IconButton>(
      find.ancestor(of: toggle, matching: find.byType(IconButton)),
    );
    expect(button.isSelected, isTrue);

    // The same symbol, drawn solid through the font's fill axis
    final drawn = tester.widget<RichText>(
      find.descendant(of: toggle, matching: find.byType(RichText)),
    );
    expect(drawn.text.style?.fontVariations, contains(const FontVariation('FILL', 1)));
  });

  testWidgets('Tab from the field reaches the chevron and Enter opens the flyout', (
    tester,
  ) async {
    await tester.pumpWidget(field());
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.text('16 x 16'), findsOneWidget);
  });

  testWidgets('the chevron highlight is smaller than the field and clear of its outline', (
    tester,
  ) async {
    await tester.pumpWidget(field());

    final chevron = tester.getRect(find.byTooltip('Sizes'));
    final inside = tester.getRect(find.byType(TextField)).deflate(3);
    expect(chevron.size, const Size.square(24));
    expect(inside.contains(chevron.topLeft) && inside.contains(chevron.bottomRight), isTrue);
  });
}
