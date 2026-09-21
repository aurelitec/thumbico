// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thumbico/services/window_placement.dart';
import 'package:win32/win32.dart';

import '../widget_host.dart';

/// A hidden top-level window of the test's own, since the app's window cannot exist in a test.
Pointer<Void> _createWindow() => using((arena) {
  final window = CreateWindowEx(
    const WINDOW_EX_STYLE(0),
    'STATIC'.toPcwstr(allocator: arena),
    null,
    WS_OVERLAPPEDWINDOW,
    50,
    50,
    400,
    300,
    null,
    null,
    null,
    null,
  ).value;
  addTearDown(() => DestroyWindow(window));
  return Pointer.fromAddress(window.address);
});

/// Whether the test's [window] is cloaked, asked of the desktop compositor itself.
bool _isCloaked(Pointer<Void> window) => using((arena) {
  final cloaked = arena<Int32>();
  DwmGetWindowAttribute(HWND(window), DWMWA_CLOAKED, cloaked, sizeOf<Int32>());
  return cloaked.value != 0;
});

void main() {
  disableWindowingForTests();

  group('a saved placement', () {
    test('is whole when the file held all of it', () {
      final placement = WindowPlacement.tryFrom(
        left: -9,
        top: 831,
        width: 1933,
        height: 1096,
        maximized: true,
      );

      expect(placement, const WindowPlacement(-9, 831, 1933, 1096, maximized: true));
    });

    test('is nothing while any part of the rectangle is missing', () {
      expect(WindowPlacement.tryFrom(top: 1, width: 800, height: 600), isNull);
      expect(WindowPlacement.tryFrom(left: 1, width: 800, height: 600), isNull);
      expect(WindowPlacement.tryFrom(left: 1, top: 1, height: 600), isNull);
      expect(WindowPlacement.tryFrom(left: 1, top: 1, width: 800), isNull);
    });

    test('is nothing when the rectangle has no area, as a damaged file could say', () {
      expect(WindowPlacement.tryFrom(left: 1, top: 1, width: 0, height: 600), isNull);
      expect(WindowPlacement.tryFrom(left: 1, top: 1, width: 800, height: -600), isNull);
    });
  });

  group('on a real window', () {
    test('an applied placement is read back as it was given', () {
      final window = _createWindow();
      const placement = WindowPlacement(120, 80, 900, 700);

      applyWindowPlacement(window, placement);

      expect(readWindowPlacement(window), placement);
    });

    test('applying a placement leaves the window hidden', () {
      final window = _createWindow();

      applyWindowPlacement(window, const WindowPlacement(120, 80, 900, 700));

      expect(isWindowVisible(window), isFalse);
    });

    test('a maximized window reads as maximized, with the rectangle from before', () {
      final window = _createWindow();
      applyWindowPlacement(window, const WindowPlacement(120, 80, 900, 700));

      ShowWindow(HWND(window), SW_SHOWMAXIMIZED);

      expect(
        readWindowPlacement(window),
        const WindowPlacement(120, 80, 900, 700, maximized: true),
      );
    });

    test('nothing is read from a handle that is not a window', () {
      expect(readWindowPlacement(Pointer.fromAddress(0)), isNull);
    });
  });

  group('a window that is to open maximized', () {
    // The engine shows a window at its first frame with a plain show, which restores a window
    // maximized before it; the tests play the engine's part with the same call.
    void showAsTheEngineDoes(Pointer<Void> window) => ShowWindow(HWND(window), SW_SHOWNORMAL);

    testWidgets('is cloaked at once and left alone while it is hidden', (tester) async {
      final window = _createWindow();
      var maximized = false;

      final done = maximizeWhenShown(window, () => maximized = true);
      await tester.pump(const Duration(milliseconds: 100));

      expect(_isCloaked(window), isTrue);
      expect(maximized, isFalse);

      showAsTheEngineDoes(window);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await tester.pump();
      await done;
    });

    testWidgets('is maximized once it is shown, and uncloaked after it has drawn', (tester) async {
      final window = _createWindow();

      final done = maximizeWhenShown(window, () => ShowWindow(HWND(window), SW_MAXIMIZE));
      showAsTheEngineDoes(window);
      await tester.pump(const Duration(milliseconds: 100));

      expect(IsZoomed(HWND(window)), isTrue);
      expect(_isCloaked(window), isTrue, reason: 'no frame has been drawn at the new size yet');

      await tester.pump();
      await tester.pump();
      await done;

      expect(_isCloaked(window), isFalse);
      expect(IsZoomed(HWND(window)), isTrue);
    });

    testWidgets('is uncloaked even if maximizing fails', (tester) async {
      final window = _createWindow();

      // Listened to from the start, or the failure would reach the test's zone unhandled
      final failed = expectLater(
        maximizeWhenShown(window, () => throw StateError('gone')),
        throwsStateError,
      );
      showAsTheEngineDoes(window);
      await tester.pump(const Duration(milliseconds: 100));
      await failed;

      expect(_isCloaked(window), isFalse);
    });

    testWidgets('is uncloaked if it is never seen shown, and then not maximized', (tester) async {
      final window = _createWindow();
      var maximized = false;

      final done = maximizeWhenShown(window, () => maximized = true);
      await tester.pump(const Duration(seconds: 6));
      await done;

      expect(_isCloaked(window), isFalse);
      expect(maximized, isFalse);
    });
  });
}
