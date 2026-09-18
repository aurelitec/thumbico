// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:material_ui/material_ui.dart';

/// The application theme, shared by every window.
ThemeData appTheme() {
  return ThemeData(
    colorScheme: _lightColors,

    // Sizes come from Material's own desktop density rather than from numbers of ours. Both are
    // already the defaults on Windows; stating them gives a test, which counts as a touch
    // platform, the same sizes as the app.
    visualDensity: .compact,
    materialTapTargetSize: .shrinkWrap,

    // A press darkens the control, as on Windows, with no ripple spreading from the pointer
    splashFactory: NoSplash.splashFactory,

    // Windows corners on what Material draws as a circle or a pill, and icons at the size the
    // Fluent set is drawn for, in the text colour its thin strokes need
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        shape: _controlShape,
        iconSize: 20,
      ).copyWith(foregroundColor: WidgetStateProperty.fromMap(_iconButtonColors)),
    ),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(shape: _controlShape)),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(shape: _controlShape),
    ),

    // Fields as Windows draws them: the white fill shows the field on the grey bar, and the
    // outline stays faint until the field has focus
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: _lightColors.surface,
      // Fainter than Material's, which greys the fill down to the bar's own colour
      hoverColor: _lightColors.onSurface.withValues(alpha: 0.03),
      border: const OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _lightColors.outlineVariant),
      ),
    ),

    // A mark on a button states a fact, so it takes the accent rather than the error red
    badgeTheme: const BadgeThemeData(backgroundColor: _accent),

    // Menu rows with a rounded hover
    menuButtonTheme: MenuButtonThemeData(style: MenuItemButton.styleFrom(shape: _controlShape)),

    // Room around the rows, so the hover stops short of the menu's edges
    menuTheme: const MenuThemeData(style: MenuStyle(padding: WidgetStatePropertyAll(.all(4)))),
  );
}

/// What an icon button draws its icon in: the accent while selected, faded while disabled, and
/// otherwise the text colour, which the Fluent set's thin strokes need to stay legible.
final _iconButtonColors = <WidgetStatesConstraint, Color>{
  WidgetState.disabled: _lightColors.onSurface.withValues(alpha: 0.38),
  WidgetState.selected: _lightColors.primary,
  WidgetState.any: _lightColors.onSurface,
};

/// The corners of a Windows control.
const _controlShape = RoundedRectangleBorder(borderRadius: .all(.circular(4)));

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
