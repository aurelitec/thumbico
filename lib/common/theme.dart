// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:material_ui/material_ui.dart';

/// The application theme, shared by every window.
ThemeData appTheme() {
  return ThemeData(colorScheme: _lightColors);
}

/// The Aurelitec blue, darkened until white text on it and its own text on white both read
/// clearly.
const _accent = Color(0xFF0A78AD);

/// Windows 11 greys around a pure white canvas, with the accent as the only colour.
///
/// Written out rather than seeded: a seed tints every surface, and the chrome must stay neutral
/// beside whatever image is shown. Roles left out fall back to the ones given here.
const _lightColors = ColorScheme(
  brightness: .light,

  // The accent, for whatever is on, selected, or focused
  primary: _accent,
  onPrimary: Color(0xFFFFFFFF),
  // Must differ from the accent: a switch that is on draws its knob in this colour under the pointer
  primaryContainer: Color(0xFFD6EEFA),
  onPrimaryContainer: Color(0xFF0A3A52),
  secondary: _accent,
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: _accent,
  onSecondaryContainer: Color(0xFFFFFFFF),

  error: Color(0xFFC42B1C),
  onError: Color(0xFFFFFFFF),

  // The canvas, and the text on every surface
  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF1B1B1B),
  onSurfaceVariant: Color(0xFF5D5D5D),

  // The bars, the flyouts, and the menus, in steps of the same grey
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFF9F9F9),
  surfaceContainer: Color(0xFFF3F3F3),
  surfaceContainerHigh: Color(0xFFEBEBEB),
  surfaceContainerHighest: Color(0xFFE5E5E5),
  surfaceDim: Color(0xFFE5E5E5),
  surfaceBright: Color(0xFFFFFFFF),

  // Field and control borders, then the fainter dividers
  outline: Color(0xFF8D8D8D),
  outlineVariant: Color(0xFFD1D1D1),

  // Raised surfaces keep their own grey instead of taking a wash of the accent
  surfaceTint: Color(0x00000000),
);
