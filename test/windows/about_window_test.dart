// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:thumbico/common/strings.dart' as strings;
import 'package:thumbico/common/theme.dart';
import 'package:thumbico/common/urls.dart' as urls;
import 'package:thumbico/windows/about_window.dart';

import '../widget_host.dart';

void main() {
  disableWindowingForTests();

  // The content must fit a window of a stated size, and the test font draws every character as
  // a full square, about twice the real width. Windows' own font is loaded under the name a
  // test's theme asks for, since a test counts as Android.
  setUpAll(() async {
    final font = File(r'C:\Windows\Fonts\segoeui.ttf').readAsBytes();
    await (FontLoader('Roboto')..addFont(font.then((bytes) => ByteData.sublistView(bytes)))).load();
  });

  /// The content as the window hosts it: a theme and a text direction with no app around it,
  /// in exactly the room the window gives it.
  Widget hosted({VoidCallback? onClose, void Function(String url)? onOpenUrl}) => Theme(
    data: appTheme(),
    child: Directionality(
      textDirection: .ltr,
      child: Center(
        child: SizedBox.fromSize(
          size: AboutWindow.size,
          child: AboutWindow(onClose: onClose ?? () {}, onOpenUrl: onOpenUrl ?? (_) {}),
        ),
      ),
    ),
  );

  testWidgets('shows the name and the version, and fits the window without overflowing', (
    tester,
  ) async {
    await tester.pumpWidget(hosted());

    expect(find.text('Thumbico'), findsOneWidget);
    expect(find.text('Version ${strings.appVersion}'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the content has room around it in a window of the stated size', (tester) async {
    await tester.pumpWidget(hosted());
    await tester.pumpAndSettle();

    final content = tester.getSize(find.byType(Column));
    expect(content.width, lessThanOrEqualTo(AboutWindow.size.width - 2 * 24));
    expect(content.height, lessThanOrEqualTo(AboutWindow.size.height - 2 * 24));
  });

  testWidgets('shows the icon, whose it is, and the licence', (tester) async {
    await tester.pumpWidget(hosted());
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    expect(find.textContaining('Aurelitec'), findsOneWidget);
    expect(find.textContaining('MIT License'), findsOneWidget);
  });

  testWidgets('each link asks for its own address', (tester) async {
    final opened = <String>[];
    await tester.pumpWidget(hosted(onOpenUrl: opened.add));

    await tester.tap(find.text('www.aurelitec.com/thumbico'));
    await tester.tap(find.text('Source code on GitHub'));

    expect(opened, [urls.home, urls.source]);
  });

  testWidgets('the Close button closes the window', (tester) async {
    var closes = 0;
    await tester.pumpWidget(hosted(onClose: () => closes++));

    await tester.tap(find.text('Close'));

    expect(closes, 1);
  });

  testWidgets('Escape closes the window before anything is clicked', (tester) async {
    var closes = 0;
    await tester.pumpWidget(hosted(onClose: () => closes++));
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);

    expect(closes, 1);
  });

  test('the version shown is the one in pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(r'^version:\s*([0-9.]+)', multiLine: true).firstMatch(pubspec)![1];
    expect(strings.appVersion, version);
  });
}
