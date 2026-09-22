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
    bool checkerboard = true,
    ValueChanged<bool>? onCheckerboardChanged,
    VoidCallback? onShowcase,
    VoidCallback? onHelp,
    VoidCallback? onAbout,
    VoidCallback? onExit,
  }) {
    return host(
      OverflowMenu(
        menuData: OverflowMenuData(
          onSaveAs: onSaveAs,
          onCopy: onCopy,
          checkerboard: checkerboard,
          onCheckerboardChanged: onCheckerboardChanged ?? (_) {},
          onShowcase: onShowcase ?? () {},
          onHelp: onHelp ?? () {},
          onAbout: onAbout ?? () {},
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
    'the More button opens the menu with Save as, Copy, Transparency grid, Showcase mode, Help, About, and Exit in that order',
    (tester) async {
      await tester.pumpWidget(menu());
      expect(find.text('Help'), findsNothing);

      await open(tester);

      final saveAs = tester.getCenter(find.text('Save as...'));
      final copy = tester.getCenter(find.text('Copy'));
      final grid = tester.getCenter(find.text('Transparency grid'));
      final showcase = tester.getCenter(find.text('Showcase mode'));
      final help = tester.getCenter(find.text('Help'));
      final about = tester.getCenter(find.text('About Thumbico'));
      final exit = tester.getCenter(find.text('Exit'));
      expect(saveAs.dy, lessThan(copy.dy));
      expect(copy.dy, lessThan(grid.dy));
      expect(grid.dy, lessThan(showcase.dy));
      expect(showcase.dy, lessThan(help.dy));
      expect(help.dy, lessThan(about.dy));
      expect(about.dy, lessThan(exit.dy));
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

    expect(lines[0], inExclusiveRange(row('Copy'), row('Transparency grid')));
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
            menuData: OverflowMenuData(
              checkerboard: true,
              onCheckerboardChanged: (_) {},
              onShowcase: () {},
              onHelp: () {},
              onAbout: () {},
              onExit: () {},
            ),
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

  testWidgets('picking Save as reports it', (tester) async {
    var saves = 0;
    await tester.pumpWidget(menu(onSaveAs: () => saves++));
    await open(tester);

    await tester.tap(find.text('Save as...'));
    await tester.pumpAndSettle();

    expect(saves, 1);
  });

  testWidgets('Save as is disabled when there is nothing to save', (tester) async {
    await tester.pumpWidget(menu());
    await open(tester);

    final item = tester.widget<MenuItemButton>(
      find.ancestor(of: find.text('Save as...'), matching: find.byType(MenuItemButton)),
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

  testWidgets('Transparency grid shows whether the grid is on', (tester) async {
    bool checked() => tester
        .widget<CheckboxMenuButton>(
          find.widgetWithText(CheckboxMenuButton, 'Transparency grid'),
        )
        .value!;

    await tester.pumpWidget(menu(checkerboard: true));
    await open(tester);
    expect(checked(), isTrue);

    await tester.pumpWidget(menu(checkerboard: false));
    await tester.pumpAndSettle();
    expect(checked(), isFalse);
  });

  testWidgets('toggling Transparency grid reports the new state and closes the menu', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(menu(checkerboard: true, onCheckerboardChanged: changes.add));
    await open(tester);

    await tester.tap(find.text('Transparency grid'));
    await tester.pumpAndSettle();

    expect(changes, [false]);
    expect(find.text('Transparency grid'), findsNothing);
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

  testWidgets('picking About reports it and closes the menu', (tester) async {
    var abouts = 0;
    await tester.pumpWidget(menu(onAbout: () => abouts++));
    await open(tester);

    await tester.tap(find.text('About Thumbico'));
    await tester.pumpAndSettle();

    expect(abouts, 1);
    expect(find.text('About Thumbico'), findsNothing);
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

  testWidgets('every command carries an icon, and the checked item its box', (tester) async {
    await tester.pumpWidget(menu());
    await open(tester);

    // Six commands with their icons and the More button's, and one checked row with a box
    expect(find.byType(Icon), findsNWidgets(7));
    expect(find.byType(Checkbox), findsOneWidget);
  });
}
