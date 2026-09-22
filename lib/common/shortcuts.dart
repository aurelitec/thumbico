// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// The keyboard shortcuts, one activator per command.
///
/// The window binds them. The menu and the tooltips show them as text of their own, which a test
/// keeps equal to these. The editing keys, Ctrl with C, V, X, A, and Z, belong to the text fields,
/// which is why Copy takes Shift.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Opens the file dialog.
const openFile = SingleActivator(LogicalKeyboardKey.keyO, control: true);

/// Opens the folder dialog.
const openFolder = SingleActivator(LogicalKeyboardKey.keyO, control: true, shift: true);

/// Reads the item in the path field again.
const refresh = SingleActivator(LogicalKeyboardKey.f5);

/// The same read from the key Explorer and the browsers also take; the menu shows F5 alone.
const refreshCtrlR = SingleActivator(LogicalKeyboardKey.keyR, control: true);

/// Puts the caret in the path field with its text selected, as the address bar keys do.
const focusPath = SingleActivator(LogicalKeyboardKey.keyL, control: true);

/// Saves the image to a file.
const saveAs = SingleActivator(LogicalKeyboardKey.keyS, control: true);

/// Copies the image to the clipboard.
const copy = SingleActivator(LogicalKeyboardKey.keyC, control: true, shift: true);

/// Opens the help page in the browser.
const help = SingleActivator(LogicalKeyboardKey.f1);

/// Steps the size up. The main keyboard's plus is the equals key unshifted, as browsers bind it.
const bigger = SingleActivator(LogicalKeyboardKey.equal, control: true);

/// The same step from the numeric keypad, whose plus needs no shift.
const biggerNumpad = SingleActivator(LogicalKeyboardKey.numpadAdd, control: true);

/// Steps the size down.
const smaller = SingleActivator(LogicalKeyboardKey.minus, control: true);

/// The same step from the numeric keypad.
const smallerNumpad = SingleActivator(LogicalKeyboardKey.numpadSubtract, control: true);

/// Enters and leaves Showcase mode; the key every full-screen view on Windows uses.
const showcase = SingleActivator(LogicalKeyboardKey.f11);

/// Exits Showcase mode; bound only while the mode is on, so Escape stays free otherwise.
const exitShowcase = SingleActivator(LogicalKeyboardKey.escape);
