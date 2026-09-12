// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter_test/flutter_test.dart';
import 'package:thumbico/widgets/status_bar.dart';
import 'package:thumbico_core/thumbico_core.dart';

import '../widget_host.dart';

void main() {
  disableWindowingForTests();

  testWidgets('shows the message and empty panes before any read', (tester) async {
    await tester.pumpWidget(host(const StatusBar(message: 'Hello')));
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
}
