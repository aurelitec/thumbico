// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

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

  testWidgets('Enter in the field submits what was typed', (tester) async {
    var submits = 0;
    await tester.pumpWidget(field(onSubmitted: () => submits++));

    await tester.enterText(find.byType(TextField), '512');
    await tester.testTextInput.receiveAction(TextInputAction.done);

    expect(submits, 1);
    expect(controller.text, '512');
  });

  testWidgets('the chevron opens a list of the standard sizes in the one format', (tester) async {
    await tester.pumpWidget(field());
    expect(find.text('16 x 16'), findsNothing);

    await tester.tap(find.byTooltip('Standard sizes'));
    await tester.pumpAndSettle();

    expect(find.byType(MenuItemButton), findsNWidgets(SizeField.presets.length));
    expect(find.text('16 x 16'), findsOneWidget);
    expect(find.text('2048 x 2048'), findsOneWidget);
  });

  testWidgets('picking a standard size writes it to the field and submits', (tester) async {
    var submits = 0;
    await tester.pumpWidget(field(onSubmitted: () => submits++));

    await tester.tap(find.byTooltip('Standard sizes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('512 x 512'));
    await tester.pumpAndSettle();

    expect(controller.text, '512 x 512');
    expect(submits, 1);
    expect(find.byType(MenuItemButton), findsNothing, reason: 'the list closes on a pick');
  });
}
