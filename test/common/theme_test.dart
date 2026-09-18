// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import 'package:thumbico/common/theme.dart';
import 'package:thumbico/widgets/overflow_menu.dart';
import 'package:thumbico/widgets/size_field.dart';

import '../widget_host.dart';

void main() {
  disableWindowingForTests();

  final colors = appTheme().colorScheme;

  test('the canvas is pure white', () {
    expect(colors.surface, const Color(0xFFFFFFFF));
  });

  test('no surface carries a tint', () {
    final surfaces = [
      colors.surface,
      colors.surfaceContainerLowest,
      colors.surfaceContainerLow,
      colors.surfaceContainer,
      colors.surfaceContainerHigh,
      colors.surfaceContainerHighest,
      colors.surfaceDim,
      colors.surfaceBright,
    ];
    for (final surface in surfaces) {
      expect(
        surface.r == surface.g && surface.g == surface.b,
        isTrue,
        reason: '$surface is tinted',
      );
    }
  });

  test('nothing ripples', () {
    expect(appTheme().splashFactory, NoSplash.splashFactory);
  });

  test('buttons and segments have square corners instead of pills and circles', () {
    final theme = appTheme();
    final shapes = [
      theme.iconButtonTheme.style?.shape?.resolve({}),
      theme.filledButtonTheme.style?.shape?.resolve({}),
      theme.segmentedButtonTheme.style?.shape?.resolve({}),
    ];
    for (final shape in shapes) {
      expect(shape, isA<RoundedRectangleBorder>());
    }
  });

  /// A widget under the application theme, as the window shows it.
  Widget themed(Widget child) => MaterialApp(
    theme: appTheme(),
    home: Material(child: child),
  );

  test('density and tap targets are the desktop ones on every platform, tests included', () {
    expect(appTheme().visualDensity, VisualDensity.compact);
    expect(appTheme().materialTapTargetSize, MaterialTapTargetSize.shrinkWrap);
  });

  testWidgets('a menu row has Material\'s compact height, with a rounded hover', (tester) async {
    await tester.pumpWidget(
      themed(
        OverflowMenu(
          callbacks: OverflowCallbacks(onShowcase: () {}, onHelp: () {}, onExit: () {}),
        ),
      ),
    );
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();

    final row = find.widgetWithText(MenuItemButton, 'Help');
    expect(tester.getSize(row).height, 40);
    final shape =
        tester.widget<MenuItemButton>(row).style?.shape ?? appTheme().menuButtonTheme.style?.shape;
    expect(shape?.resolve({}), isA<RoundedRectangleBorder>());
  });

  testWidgets('a menu row draws its icon as a toolbar button does', (tester) async {
    await tester.pumpWidget(
      themed(
        OverflowMenu(
          callbacks: OverflowCallbacks(onShowcase: () {}, onHelp: () {}, onExit: () {}),
        ),
      ),
    );
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();

    final style = tester
        .widget<RichText>(
          find.descendant(of: find.byIcon(Symbols.help), matching: find.byType(RichText)),
        )
        .text
        .style!;
    expect(style.fontSize, 20);
    expect(style.color, colors.onSurface);
  });

  testWidgets('a menu label is regular weight, and otherwise Material\'s own label style', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(
        OverflowMenu(
          callbacks: OverflowCallbacks(onShowcase: () {}, onHelp: () {}, onExit: () {}),
        ),
      ),
    );
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();

    final label = find.text('Help');
    final drawn = tester
        .widget<RichText>(find.descendant(of: label, matching: find.byType(RichText)))
        .text
        .style!;
    final material = Theme.of(tester.element(label)).textTheme.labelLarge!;

    expect(drawn.fontWeight, FontWeight.w400);
    expect(drawn.fontSize, material.fontSize);
    expect(drawn.fontFamily, material.fontFamily);
    expect(drawn.letterSpacing, material.letterSpacing);
  });

  /// The raised surface a menu or a flyout is drawn on, found from some text inside it.
  Material cardAround(WidgetTester tester, String text) => tester
      .widgetList<Material>(find.ancestor(of: find.text(text), matching: find.byType(Material)))
      .firstWhere((material) => material.elevation > 0);

  void expectCard(Material card) {
    expect(card.color, colors.surfaceContainerLow);
    final shape = card.shape! as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(8));
    expect(shape.side.color, colors.outlineVariant);
  }

  testWidgets('a menu is a light card with round corners and a faint edge', (tester) async {
    await tester.pumpWidget(
      themed(
        OverflowMenu(
          callbacks: OverflowCallbacks(onShowcase: () {}, onHelp: () {}, onExit: () {}),
        ),
      ),
    );
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();

    expectCard(cardAround(tester, 'Help'));
  });

  testWidgets('a flyout with a style of its own is the same card', (tester) async {
    final controller = TextEditingController(text: '256 x 256');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      themed(
        SizeField(
          controller: controller,
          onSubmitted: () {},
          onBigger: () {},
          onSmaller: () {},
          scaleToDisplay: false,
          onScaleToDisplayChanged: (_) {},
        ),
      ),
    );
    await tester.tap(find.byTooltip('Sizes'));
    await tester.pumpAndSettle();

    expectCard(cardAround(tester, '512 x 512'));
  });

  test('a menu row is inset from the edges of its menu', () {
    expect(appTheme().menuTheme.style?.padding?.resolve({}), const EdgeInsets.all(4));
  });

  testWidgets('a standard size row is as tall as a menu row', (tester) async {
    final controller = TextEditingController(text: '256 x 256');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      themed(
        SizeField(
          controller: controller,
          onSubmitted: () {},
          onBigger: () {},
          onSmaller: () {},
          scaleToDisplay: false,
          onScaleToDisplayChanged: (_) {},
        ),
      ),
    );
    await tester.tap(find.byTooltip('Sizes'));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.widgetWithText(MenuItemButton, '512 x 512')).height, 40);
  });

  testWidgets('a field is a white box with a faint outline, as on Windows', (tester) async {
    final controller = TextEditingController(text: '256 x 256');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      themed(
        SizeField(
          controller: controller,
          onSubmitted: () {},
          onBigger: () {},
          onSmaller: () {},
          scaleToDisplay: false,
          onScaleToDisplayChanged: (_) {},
        ),
      ),
    );

    final drawn = tester.widget<InputDecorator>(find.byType(InputDecorator)).decoration;
    expect(drawn.filled, isTrue);
    expect(drawn.fillColor, colors.surface);
    expect(drawn.enabledBorder, isA<OutlineInputBorder>());
    expect(drawn.enabledBorder?.borderSide.color, colors.outlineVariant);

    // Under the pointer the fill greys a little, and stays lighter than the bar behind it
    final hovered = Color.alphaBlend(drawn.hoverColor!, drawn.fillColor!);
    expect(hovered, isNot(drawn.fillColor));
    expect(hovered.computeLuminance(), greaterThan(colors.surfaceContainer.computeLuminance()));
  });

  test('the mark on a button is the same blue as everything else that is on, not an error red', () {
    expect(appTheme().badgeTheme.backgroundColor, colors.primary);
  });

  testWidgets('button icons are drawn in the text colour, and a selected one in the accent', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(
        Row(
          children: [
            IconButton(icon: const Icon(Symbols.folder), onPressed: () {}),
            IconButton(
              isSelected: true,
              icon: const Icon(Symbols.monitor),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    Color? drawnColor(IconData icon) => tester
        .widget<RichText>(find.descendant(of: find.byIcon(icon), matching: find.byType(RichText)))
        .text
        .style
        ?.color;

    expect(drawnColor(Symbols.folder), colors.onSurface);
    expect(drawnColor(Symbols.monitor), colors.primary);
  });

  testWidgets('a button icon is drawn small, in the shape the symbols have for that size', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(IconButton(icon: const Icon(Symbols.refresh), onPressed: () {})),
    );

    final style = tester
        .widget<RichText>(
          find.descendant(of: find.byIcon(Symbols.refresh), matching: find.byType(RichText)),
        )
        .text
        .style!;
    expect(style.fontSize, 20);
    expect(style.fontVariations, contains(const FontVariation('opsz', 20)));
  });
}
