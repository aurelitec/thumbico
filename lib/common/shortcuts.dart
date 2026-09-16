// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// The keyboard shortcuts, one activator per command.
///
/// The menu shows them and the window binds them, both from here, so a label can never
/// disagree with the key that fires. The editing keys, Ctrl with C, V, X, A, and Z, are
/// left to the text fields, which is why Copy takes Shift.
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
