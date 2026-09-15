// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:thumbico/common/shortcuts.dart' as shortcuts;

import '../widget_host.dart';

void main() {
  disableWindowingForTests();

  /// Each activator with the keys that must fire it.
  const table = <String, (ShortcutActivator, List<LogicalKeyboardKey>)>{
    'openFile': (shortcuts.openFile, [LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.keyO]),
    'openFolder': (
      shortcuts.openFolder,
      [LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.shiftLeft, LogicalKeyboardKey.keyO],
    ),
    'refresh': (shortcuts.refresh, [LogicalKeyboardKey.f5]),
    'focusPath': (shortcuts.focusPath, [LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.keyL]),
    'saveAs': (shortcuts.saveAs, [LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.keyS]),
    'copy': (
      shortcuts.copy,
      [LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.shiftLeft, LogicalKeyboardKey.keyC],
    ),
    'help': (shortcuts.help, [LogicalKeyboardKey.f1]),
  };

  /// Presses the modifiers, taps the last key, and releases the modifiers.
  Future<void> press(WidgetTester tester, List<LogicalKeyboardKey> keys) async {
    for (final key in keys.sublist(0, keys.length - 1)) {
      await tester.sendKeyDownEvent(key);
    }
    await tester.sendKeyEvent(keys.last);
    for (final key in keys.sublist(0, keys.length - 1).reversed) {
      await tester.sendKeyUpEvent(key);
    }
  }

  for (final MapEntry(key: name, value: (activator, keys)) in table.entries) {
    testWidgets('$name fires on its keys and on nothing else', (tester) async {
      var fired = 0;
      await tester.pumpWidget(
        host(
          CallbackShortcuts(
            bindings: {activator: () => fired++},
            child: const Focus(autofocus: true, child: SizedBox()),
          ),
        ),
      );

      await press(tester, keys);
      expect(fired, 1);

      // Every other activator's keys must leave this one alone.
      for (final (other, otherKeys) in table.values) {
        if (!identical(other, activator)) {
          await press(tester, otherKeys);
        }
      }
      expect(fired, 1);
    });
  }
}
