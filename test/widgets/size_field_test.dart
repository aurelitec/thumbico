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

  Widget field({VoidCallback? onSubmitted}) =>
      host(SizeField(controller: controller, onSubmitted: onSubmitted ?? () {}));

  /// What one Enter press does on Windows: a key event, then the field's submit action.
  Future<void> pressEnter(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  Future<void> openList(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.arrow_drop_down).hitTestable());
    await tester.pumpAndSettle();
  }

  testWidgets('Enter after typing submits what was typed, once', (tester) async {
    var submits = 0;
    await tester.pumpWidget(field(onSubmitted: () => submits++));

    await tester.enterText(find.byType(TextField), '512');
    await pressEnter(tester);

    expect(submits, 1);
    expect(controller.text, '512');
  });

  testWidgets('Enter with the list closed still submits, once', (tester) async {
    var submits = 0;
    await tester.pumpWidget(field(onSubmitted: () => submits++));

    await tester.enterText(find.byType(TextField), '512');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(
      find.byType(MenuItemButton).hitTestable(),
      findsNothing,
      reason: 'Escape closed the list',
    );

    await pressEnter(tester);

    expect(submits, 1);
    expect(controller.text, '512');
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

  testWidgets('Down walks the open list and puts the highlighted size in the field', (
    tester,
  ) async {
    await tester.pumpWidget(field());
    await openList(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(controller.text, '16 x 16');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(controller.text, '24 x 24');
  });

  testWidgets('the chevron opens a list of the standard sizes in the one format', (tester) async {
    await tester.pumpWidget(field());
    expect(find.text('16 x 16').hitTestable(), findsNothing);

    await openList(tester);

    expect(find.byType(MenuItemButton).hitTestable(), findsNWidgets(SizeField.presets.length));
    expect(find.text('16 x 16').hitTestable(), findsOneWidget);
    expect(find.text('2048 x 2048').hitTestable(), findsOneWidget);
  });

  testWidgets('picking a standard size writes it to the field and submits', (tester) async {
    var submits = 0;
    await tester.pumpWidget(field(onSubmitted: () => submits++));

    await openList(tester);
    await tester.tap(find.text('512 x 512').hitTestable());
    await tester.pumpAndSettle();

    expect(controller.text, '512 x 512');
    expect(submits, 1);
    expect(
      find.byType(MenuItemButton).hitTestable(),
      findsNothing,
      reason: 'the list closes on a pick',
    );
  });
}
