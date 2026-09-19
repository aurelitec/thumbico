// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:thumbico/common/theme.dart';
import 'package:thumbico/widgets/status_bar.dart';
import 'package:thumbico_core/thumbico_core.dart';

import '../widget_host.dart';

void main() {
  disableWindowingForTests();

  testWidgets('shows the message and empty panes before any read', (tester) async {
    await tester.pumpWidget(host(const StatusBar(message: StatusMessage('Hello'))));
    expect(find.text('Hello'), findsOneWidget);
    expect(find.textContaining('Asked for'), findsNothing);
    expect(find.textContaining('Returned'), findsNothing);
  });

  testWidgets('shows the requested size, the produced size, and the kind', (tester) async {
    const info = ThumbicoInfo(
      size: ThumbicoSize(256, 192),
      requestedSize: ThumbicoSize.square(256),
      isIcon: false,
    );
    await tester.pumpWidget(host(const StatusBar(info: info)));
    expect(find.text('Asked for 256 x 256'), findsOneWidget);
    expect(find.text('Returned 256 x 192'), findsOneWidget);
    expect(find.text('Thumbnail'), findsOneWidget);
  });

  testWidgets('names an icon as such', (tester) async {
    const info = ThumbicoInfo(
      size: ThumbicoSize.square(32),
      requestedSize: ThumbicoSize.square(32),
      isIcon: true,
    );
    await tester.pumpWidget(host(const StatusBar(info: info)));
    expect(find.text('Icon'), findsOneWidget);
  });

  group('a message that reports a problem', () {
    const info = ThumbicoInfo(
      size: ThumbicoSize(256, 192),
      requestedSize: ThumbicoSize.square(256),
      isIcon: false,
    );
    final colors = appTheme().colorScheme;

    /// The colour the bar is filled with.
    Color fill(WidgetTester tester) => tester
        .widget<Material>(
          find.descendant(of: find.byType(StatusBar), matching: find.byType(Material)),
        )
        .color!;

    testWidgets('takes the whole bar, hiding what the last read returned', (tester) async {
      await tester.pumpWidget(
        host(const StatusBar(message: StatusMessage.error('Not found'), info: info)),
      );

      expect(find.text('Not found'), findsOneWidget);
      expect(find.textContaining('Asked for'), findsNothing);
      expect(find.textContaining('Returned'), findsNothing);
      expect(find.text('Thumbnail'), findsNothing);
    });

    testWidgets('is marked by a filled icon and a red bar, not by colour alone', (tester) async {
      await tester.pumpWidget(
        host(const StatusBar(message: StatusMessage.error('Not found'), info: info)),
      );

      expect(fill(tester), colors.error);
      final icon = tester.widget<Icon>(find.byIcon(Symbols.error));
      expect(icon.color, colors.onError);
      expect(icon.fill, 1);
      expect(
        tester.widget<Text>(find.text('Not found')).style?.color,
        colors.onError,
      );
    });

    testWidgets('an ordinary message leaves the bar and the panes as they are', (tester) async {
      await tester.pumpWidget(
        host(const StatusBar(message: StatusMessage('Copied'), info: info)),
      );

      expect(fill(tester), colors.surfaceContainer);
      expect(find.byIcon(Symbols.error), findsNothing);
      expect(find.text('Asked for 256 x 256'), findsOneWidget);
    });
  });
}
