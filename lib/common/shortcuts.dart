// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// The keyboard shortcuts, one activator per command.
///
/// The window binds them. The menu and the tooltips show them as text of their own, which a
/// test keeps equal to these. The editing keys, Ctrl with C, V, X, A, and Z, are left to the
/// text fields, which is why Copy takes Shift.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const openFile = SingleActivator(LogicalKeyboardKey.keyO, control: true);
const openFolder = SingleActivator(LogicalKeyboardKey.keyO, control: true, shift: true);
const refresh = SingleActivator(LogicalKeyboardKey.f5);

/// Puts the caret in the path field with its text selected, as the address bar keys do.
const focusPath = SingleActivator(LogicalKeyboardKey.keyL, control: true);

const saveAs = SingleActivator(LogicalKeyboardKey.keyS, control: true);
const copy = SingleActivator(LogicalKeyboardKey.keyC, control: true, shift: true);
const help = SingleActivator(LogicalKeyboardKey.f1);

/// Doubles the size. The main keyboard's plus is the equals key unshifted, as browsers bind it.
const bigger = SingleActivator(LogicalKeyboardKey.equal, control: true);
const biggerNumpad = SingleActivator(LogicalKeyboardKey.numpadAdd, control: true);

/// Halves the size.
const smaller = SingleActivator(LogicalKeyboardKey.minus, control: true);
const smallerNumpad = SingleActivator(LogicalKeyboardKey.numpadSubtract, control: true);

/// Enters and leaves Showcase mode; the key every full-screen view on Windows uses.
const showcase = SingleActivator(LogicalKeyboardKey.f11);

/// Exits Showcase mode; bound only while the mode is on, so Escape stays free otherwise.
const exitShowcase = SingleActivator(LogicalKeyboardKey.escape);

/// Scroll the image by a small step. Bound only while nothing has focus, since a field, a menu,
/// and a flyout each need the arrows for themselves.
const scrollLeft = SingleActivator(LogicalKeyboardKey.arrowLeft);
const scrollRight = SingleActivator(LogicalKeyboardKey.arrowRight);
const scrollUp = SingleActivator(LogicalKeyboardKey.arrowUp);
const scrollDown = SingleActivator(LogicalKeyboardKey.arrowDown);

/// Scroll the image by most of a view: the Page keys up and down, and Home and End sideways,
/// as IrfanView has them. Bound only while nothing has focus, as the arrows are.
const scrollPageUp = SingleActivator(LogicalKeyboardKey.pageUp);
const scrollPageDown = SingleActivator(LogicalKeyboardKey.pageDown);
const scrollPageLeft = SingleActivator(LogicalKeyboardKey.home);
const scrollPageRight = SingleActivator(LogicalKeyboardKey.end);
