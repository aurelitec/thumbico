// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:thumbico/common/strings.dart' as strings;
import 'package:thumbico/common/theme.dart';
import 'package:thumbico/windows/about_window.dart';

import '../widget_host.dart';

void main() {
  disableWindowingForTests();

  /// The content as the window hosts it: a theme and a text direction, with no app around it
  /// and no bounds, since the window is sized to its content.
  Widget hosted({required VoidCallback onClose}) => Theme(
    data: appTheme(),
    child: Directionality(
      textDirection: .ltr,
      child: UnconstrainedBox(child: AboutWindow(onClose: onClose)),
    ),
  );

  testWidgets('shows the name and the version, and lays out without bounds', (tester) async {
    await tester.pumpWidget(hosted(onClose: () {}));

    expect(find.text('Thumbico'), findsOneWidget);
    expect(find.text('Version ${strings.appVersion}'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
