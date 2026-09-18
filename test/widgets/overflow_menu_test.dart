// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:thumbico/widgets/overflow_menu.dart';

import '../widget_host.dart';

void main() {
  disableWindowingForTests();

  Widget menu({
    VoidCallback? onSaveAs,
    VoidCallback? onCopy,
    VoidCallback? onShowcase,
    VoidCallback? onHelp,
    VoidCallback? onExit,
  }) {
    return host(
      OverflowMenu(
        callbacks: OverflowCallbacks(
          onSaveAs: onSaveAs,
          onCopy: onCopy,
          onShowcase: onShowcase ?? () {},
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

  testWidgets(
    'the More button opens the menu with Save As, Copy, Showcase mode, Help, and Exit in that order',
    (tester) async {
      await tester.pumpWidget(menu());
      expect(find.text('Help'), findsNothing);

      await open(tester);

      final saveAs = tester.getCenter(find.text('Save As...'));
      final copy = tester.getCenter(find.text('Copy'));
      final showcase = tester.getCenter(find.text('Showcase mode'));
      final help = tester.getCenter(find.text('Help'));
      final exit = tester.getCenter(find.text('Exit'));
      expect(saveAs.dy, lessThan(copy.dy));
      expect(copy.dy, lessThan(showcase.dy));
      expect(showcase.dy, lessThan(help.dy));
      expect(help.dy, lessThan(exit.dy));
    },
  );

  testWidgets('lines separate what leaves with the image, the view, and the rest', (
    tester,
  ) async {
    await tester.pumpWidget(menu());
    await open(tester);

    expect(find.byType(Divider), findsNWidgets(2));
    final lines = [for (var i = 0; i < 2; i++) tester.getCenter(find.byType(Divider).at(i)).dy];
    double row(String label) => tester.getCenter(find.text(label)).dy;

    expect(lines[0], inExclusiveRange(row('Copy'), row('Showcase mode')));
    expect(lines[1], inExclusiveRange(row('Showcase mode'), row('Help')));
  });

  testWidgets('the menu hangs from the button with no gap, as a Windows menu does', (
    tester,
  ) async {
    // At the top right, where the toolbar puts it, so the menu has room to open downwards
    await tester.pumpWidget(
      host(
        Align(
          alignment: .topRight,
          child: OverflowMenu(
            callbacks: OverflowCallbacks(onShowcase: () {}, onHelp: () {}, onExit: () {}),
          ),
        ),
      ),
    );
    await open(tester);

    final card = find
        .ancestor(of: find.text('Help'), matching: find.byType(Material))
        .evaluate()
        .map((element) => element.widget as Material)
        .firstWhere((material) => material.elevation > 0);
    expect(
      tester.getRect(find.byWidget(card)).top,
      tester.getRect(find.byType(IconButton)).bottom,
    );
  });

  testWidgets('picking Save As reports it', (tester) async {
    var saves = 0;
    await tester.pumpWidget(menu(onSaveAs: () => saves++));
    await open(tester);

    await tester.tap(find.text('Save As...'));
    await tester.pumpAndSettle();

    expect(saves, 1);
  });

  testWidgets('Save As is disabled when there is nothing to save', (tester) async {
    await tester.pumpWidget(menu());
    await open(tester);

    final item = tester.widget<MenuItemButton>(
      find.ancestor(of: find.text('Save As...'), matching: find.byType(MenuItemButton)),
    );
    expect(item.enabled, isFalse);
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

  testWidgets('picking Showcase mode reports it', (tester) async {
    var showcases = 0;
    await tester.pumpWidget(menu(onShowcase: () => showcases++));
    await open(tester);

    await tester.tap(find.text('Showcase mode'));
    await tester.pumpAndSettle();

    expect(showcases, 1);
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

  testWidgets('the items that have a shortcut show it', (tester) async {
    await tester.pumpWidget(menu());
    await open(tester);

    expect(find.text('Ctrl+S'), findsOneWidget);
    expect(find.text('Ctrl+Shift+C'), findsOneWidget);
    expect(find.text('F11'), findsOneWidget);
    expect(find.text('F1'), findsOneWidget);
  });

  testWidgets('a shortcut is fainter than its label and stands clear of it', (tester) async {
    await tester.pumpWidget(menu());
    await open(tester);

    Color colorOf(String text) => tester
        .widget<RichText>(find.descendant(of: find.text(text), matching: find.byType(RichText)))
        .text
        .style!
        .color!;
    expect(colorOf('F11').a, lessThan(colorOf('Showcase mode').a));

    // The widest row is the one where the two come closest
    final gap =
        tester.getTopLeft(find.text('F11')).dx - tester.getTopRight(find.text('Showcase mode')).dx;
    expect(gap, greaterThanOrEqualTo(24));
  });

  testWidgets('every item carries an icon', (tester) async {
    await tester.pumpWidget(menu());
    await open(tester);

    expect(find.byType(MenuItemButton), findsNWidgets(5));
    expect(find.byType(Icon), findsNWidgets(6));
  });
}
