// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// Where a window is on the desktop, to carry between runs.
///
/// The windowing API knows a window's size and nothing of its position, so this goes to Windows
/// through the window's handle, with the pair of calls Windows has for exactly this job.
library;

import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/widgets.dart';
import 'package:win32/win32.dart';

/// A window's rectangle while it is neither maximized nor minimized, and whether it is maximized.
///
/// The numbers are physical pixels in the coordinates Windows keeps placements in, which are not
/// quite the screen's, so they are good for handing back to [applyWindowPlacement] and nothing
/// else.
@immutable
class const WindowPlacement(
  /// The left edge of the window, frame included.
  final int left,

  /// The top edge of the window, frame included.
  final int top,

  /// The width of the window, frame included.
  final int width,

  /// The height of the window, frame included.
  final int height, {

  /// Whether the window fills the screen, with the rectangle being where it goes back to.
  final bool maximized = false,
}) {
  /// The placement a settings file held, or null unless it held a whole, real rectangle.
  ///
  /// A first run has none, and a file damaged by hand must not decide where the window goes.
  static WindowPlacement? tryFrom({
    int? left,
    int? top,
    int? width,
    int? height,
    bool maximized = false,
  }) {
    if (left == null || top == null || width == null || height == null) {
      return null;
    }
    if (width <= 0 || height <= 0) {
      return null;
    }
    return WindowPlacement(left, top, width, height, maximized: maximized);
  }

  @override
  bool operator ==(Object other) =>
      other is WindowPlacement &&
      other.left == left &&
      other.top == top &&
      other.width == width &&
      other.height == height &&
      other.maximized == maximized;

  @override
  int get hashCode => Object.hash(left, top, width, height, maximized);

  @override
  String toString() =>
      'WindowPlacement($left, $top, $width x $height${maximized ? ', maximized' : ''})';
}

/// The placement of [window] now, or null if Windows cannot say, as for a window already gone.
///
/// A minimized window reads as not maximized, whatever it was before.
WindowPlacement? readWindowPlacement(Pointer<Void> window) => using((arena) {
  final placement = arena<WINDOWPLACEMENT>()..ref.length = sizeOf<WINDOWPLACEMENT>();
  if (!GetWindowPlacement(HWND(window), placement).value) {
    return null;
  }
  final normal = placement.ref.rcNormalPosition;
  return WindowPlacement(
    normal.left,
    normal.top,
    normal.right - normal.left,
    normal.bottom - normal.top,
    maximized: IsZoomed(HWND(window)),
  );
});

/// Gives [window] the rectangle of [placement] and leaves it hidden, for the engine to show.
///
/// Windows brings a rectangle that lies off every screen back into view, and keeps the window's
/// own minimum size. The maximized state is not applied here: see [maximizeWhenShown].
void applyWindowPlacement(Pointer<Void> window, WindowPlacement placement) => using((arena) {
  final native = arena<WINDOWPLACEMENT>()..ref.length = sizeOf<WINDOWPLACEMENT>();
  // Read first, so the minimized and maximized positions stay whatever Windows had
  GetWindowPlacement(HWND(window), native);
  native.ref
    ..showCmd = SW_HIDE
    ..rcNormalPosition.left = placement.left
    ..rcNormalPosition.top = placement.top
    ..rcNormalPosition.right = placement.left + placement.width
    ..rcNormalPosition.bottom = placement.top + placement.height;
  SetWindowPlacement(HWND(window), native);
});

/// Whether [window] is shown, which a window made by the engine is from its first frame on.
bool isWindowVisible(Pointer<Void> window) => IsWindowVisible(HWND(window));

/// How often [maximizeWhenShown] looks whether the engine has shown the window yet.
const _lookEvery = Duration(milliseconds: 16);

/// How long [maximizeWhenShown] waits for that before it gives the window up as it is.
const _giveUpAfter = Duration(seconds: 5);

/// Opens [window] maximized: calls [maximize] as soon as the engine has shown the window, with
/// the window cloaked from now until it has drawn at its new size.
///
/// The engine shows a window at its first frame with a plain show, which restores a window
/// maximized any earlier, so maximizing has to wait for it; the cloak keeps the normal-sized
/// window that the engine shows first from being seen. The cloak always comes off again: if
/// [maximize] throws, and if the window is not seen shown within five seconds, in which case it
/// is left as it is. Call it right after [applyWindowPlacement], while the window is hidden.
Future<void> maximizeWhenShown(Pointer<Void> window, VoidCallback maximize) async {
  _setCloaked(window, true);
  try {
    for (var waited = Duration.zero; !isWindowVisible(window); waited += _lookEvery) {
      if (waited >= _giveUpAfter) {
        return;
      }
      await Future<void>.delayed(_lookEvery);
    }
    maximize();
    // One frame lays the content out at the new size and the next has it on screen
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
  } finally {
    _setCloaked(window, false);
  }
}

/// Hides [window] from the screen without changing its show state, or shows it again.
void _setCloaked(Pointer<Void> window, bool cloaked) => using((arena) {
  final value = arena<Int32>()..value = cloaked ? 1 : 0;
  DwmSetWindowAttribute(HWND(window), DWMWA_CLOAK, value, sizeOf<Int32>());
});
