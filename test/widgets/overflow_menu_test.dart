// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:thumbico/widgets/overflow_menu.dart';

import '../widget_host.dart';

void main() {
  disableWindowingForTests();

  Widget menu({VoidCallback? onCopy, VoidCallback? onHelp, VoidCallback? onExit}) {
    return host(
      OverflowMenu(
        callbacks: OverflowCallbacks(
          onCopy: onCopy,
          onHelp: onHelp ?? () {},
          onExit: onExit ?? () {},
        ),
      ),
    );
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
  }

  testWidgets('the More button opens the menu with Copy, Help, and Exit in that order', (
    tester,
  ) async {
    await tester.pumpWidget(menu());
    expect(find.text('Help'), findsNothing);

    await open(tester);

    final copy = tester.getCenter(find.text('Copy'));
    final help = tester.getCenter(find.text('Help'));
    final exit = tester.getCenter(find.text('Exit'));
    expect(copy.dy, lessThan(help.dy));
    expect(help.dy, lessThan(exit.dy));
  });

  testWidgets('picking Copy reports it', (tester) async {
    var copies = 0;
    await tester.pumpWidget(menu(onCopy: () => copies++));
    await open(tester);

    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();

    expect(copies, 1);
  });

  testWidgets('Copy is disabled when there is nothing to copy', (tester) async {
    await tester.pumpWidget(menu());
    await open(tester);

    final item = tester.widget<MenuItemButton>(
      find.ancestor(of: find.text('Copy'), matching: find.byType(MenuItemButton)),
    );
    expect(item.enabled, isFalse);
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

    expect(find.byType(MenuItemButton), findsNWidgets(3));
    expect(find.byType(Icon), findsNWidgets(4));
  });
}
