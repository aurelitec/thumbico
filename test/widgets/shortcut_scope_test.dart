// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:thumbico/widgets/overflow_menu.dart';
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

  group('a binding for while nothing has focus', () {
    const left = SingleActivator(LogicalKeyboardKey.arrowLeft);
    const down = SingleActivator(LogicalKeyboardKey.arrowDown);

    testWidgets('fires at start, and again after a field gives up focus', (tester) async {
      var fired = 0;
      await tester.pumpWidget(
        host(
          ShortcutScope(
            bindings: const {},
            unfocusedBindings: {left: () => fired++},
            child: const TextField(),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      expect(fired, 1);

      await tester.tap(find.byType(TextField));
      await tester.pump();
      tester.binding.focusManager.primaryFocus!.unfocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      expect(fired, 2);
    });

    testWidgets('leaves the key to a focused field, where it moves the caret', (tester) async {
      var fired = 0;
      final text = TextEditingController(text: 'abc');
      addTearDown(text.dispose);
      await tester.pumpWidget(
        host(
          ShortcutScope(
            bindings: const {},
            unfocusedBindings: {left: () => fired++},
            child: TextField(controller: text, autofocus: true),
          ),
        ),
      );
      await tester.pump();
      text.selection = const TextSelection.collapsed(offset: 3);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(fired, 0);
      expect(text.selection.baseOffset, 2);
    });

    testWidgets('leaves the key to an open menu, where it walks the rows', (tester) async {
      var fired = 0;
      await tester.pumpWidget(
        host(
          ShortcutScope(
            bindings: const {},
            unfocusedBindings: {down: () => fired++},
            child: OverflowMenu(
              callbacks: OverflowCallbacks(onShowcase: () {}, onHelp: () {}, onExit: () {}),
            ),
          ),
        ),
      );
      await tester.tap(find.byTooltip('More'));
      await tester.pumpAndSettle();

      // A row takes focus when the pointer enters it, which is how a menu opened by the mouse
      // comes to hold the focus
      final mouse = await tester.createGesture(kind: .mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer();
      await mouse.moveTo(tester.getCenter(find.text('Showcase mode')));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(fired, 0);
      expect(
        Focus.of(tester.element(find.text('Help'))).hasPrimaryFocus,
        isTrue,
        reason: 'the arrow moved from the hovered row to the next one',
      );
    });

    testWidgets('fires on every repeat of a held key', (tester) async {
      var fired = 0;
      await tester.pumpWidget(
        host(
          ShortcutScope(
            bindings: const {},
            unfocusedBindings: {left: () => fired++},
            child: const SizedBox(),
          ),
        ),
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowLeft);

      expect(fired, 3);
    });
  });
}
