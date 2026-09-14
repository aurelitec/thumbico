// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:thumbico/widgets/overflow_menu.dart';

import '../widget_host.dart';

void main() {
  disableWindowingForTests();

  Widget menu({VoidCallback? onHelp, VoidCallback? onExit}) {
    return host(
      OverflowMenu(
        callbacks: OverflowCallbacks(onHelp: onHelp ?? () {}, onExit: onExit ?? () {}),
      ),
    );
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
  }

  testWidgets('the More button opens the menu with Help above Exit', (tester) async {
    await tester.pumpWidget(menu());
    expect(find.text('Help'), findsNothing);

    await open(tester);

    final help = tester.getCenter(find.text('Help'));
    final exit = tester.getCenter(find.text('Exit'));
    expect(help.dy, lessThan(exit.dy));
  });

  testWidgets('picking Help reports it and closes the menu', (tester) async {
    var helps = 0;
    await tester.pumpWidget(menu(onHelp: () => helps++));
    await open(tester);

    await tester.tap(find.text('Help'));
    await tester.pumpAndSettle();

    expect(helps, 1);
    expect(find.text('Help'), findsNothing);
  });

  testWidgets('picking Exit reports it', (tester) async {
    var exits = 0;
    await tester.pumpWidget(menu(onExit: () => exits++));
    await open(tester);

    await tester.tap(find.text('Exit'));
    await tester.pumpAndSettle();

    expect(exits, 1);
  });

  testWidgets('every item carries an icon', (tester) async {
    await tester.pumpWidget(menu());
    await open(tester);

    expect(find.byType(MenuItemButton), findsNWidgets(2));
    expect(find.byType(Icon), findsNWidgets(3));
  });
}
