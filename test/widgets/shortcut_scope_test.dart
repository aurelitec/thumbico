// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:thumbico/widgets/shortcut_scope.dart';

import '../widget_host.dart';

void main() {
  disableWindowingForTests();

  const refresh = SingleActivator(LogicalKeyboardKey.f5);

  /// A field that starts focused, as the path field does.
  Widget scope({required VoidCallback onRefresh}) {
    return host(
      ShortcutScope(
        bindings: {refresh: onRefresh},
        child: const TextField(autofocus: true),
      ),
    );
  }

  testWidgets('a shortcut fires at start with no field focused', (tester) async {
    var fired = 0;
    await tester.pumpWidget(
      host(ShortcutScope(bindings: {refresh: () => fired++}, child: const TextField())),
    );
    final field = tester.widget<EditableText>(find.byType(EditableText));
    expect(field.focusNode.hasFocus, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.f5);

    expect(fired, 1);
  });

  testWidgets('a shortcut fires while the field has focus', (tester) async {
    var fired = 0;
    await tester.pumpWidget(scope(onRefresh: () => fired++));

    await tester.sendKeyEvent(LogicalKeyboardKey.f5);

    expect(fired, 1);
  });

  testWidgets('a shortcut still fires after the field gives up focus', (tester) async {
    var fired = 0;
    await tester.pumpWidget(scope(onRefresh: () => fired++));

    // A click on the image makes the field give up focus, which is this call; the test
    // harness's pointer events do not reach the field's tap region, so it is made directly.
    tester.binding.focusManager.primaryFocus!.unfocus();
    await tester.pump();
    final field = tester.widget<EditableText>(find.byType(EditableText));
    expect(field.focusNode.hasFocus, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.f5);

    expect(fired, 1);
  });
}
