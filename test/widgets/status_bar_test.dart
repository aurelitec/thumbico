// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:typed_data';

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
    final image = ThumbicoImage(
      width: 256,
      height: 192,
      requestedSize: const ThumbicoSize.square(256),
      isIcon: false,
      pixels: Uint8List(256 * 192 * 4),
    );
    await tester.pumpWidget(
      host(StatusBar(requested: const ThumbicoSize.square(256), image: image)),
    );
    expect(find.text('Asked for 256 x 256'), findsOneWidget);
    expect(find.text('Returned 256 x 192'), findsOneWidget);
    expect(find.text('Thumbnail'), findsOneWidget);
  });

  testWidgets('names an icon as such', (tester) async {
    final image = ThumbicoImage(
      width: 32,
      height: 32,
      requestedSize: const ThumbicoSize.square(32),
      isIcon: true,
      pixels: Uint8List(32 * 32 * 4),
    );
    await tester.pumpWidget(
      host(StatusBar(requested: const ThumbicoSize.square(32), image: image)),
    );
    expect(find.text('Icon'), findsOneWidget);
  });
}
