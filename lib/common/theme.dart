// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:material_ui/material_ui.dart';

/// The application theme, shared by every window.
ThemeData appTheme() {
  return ThemeData(
    colorScheme: _lightColors,

    // Material's desktop defaults, stated so that a test, which counts as a touch platform,
    // measures the same sizes as the app
    visualDensity: .compact,
    materialTapTargetSize: .shrinkWrap,

    // A press darkens the control, as on Windows, with no ripple spreading from the pointer
    splashFactory: NoSplash.splashFactory,

    // Icons at the smallest size the symbols are designed for, in the shape drawn for that size
    iconTheme: const IconThemeData(size: _iconSize, opticalSize: _iconSize),

    // Small corners on what Material draws as a circle or a pill, and icons in the text colour.
    // An icon button sizes its own icon, so the size is repeated here.
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        shape: _controlShape,
        iconSize: _iconSize,
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

    // Menu rows with a rounded hover. A menu row sizes and colours its own icon, as an icon
    // button does, so both are repeated here to match the toolbar.
    menuButtonTheme: MenuButtonThemeData(
      style: MenuItemButton.styleFrom(
        shape: _controlShape,
        iconSize: _iconSize,
        iconColor: _lightColors.onSurface,
        textStyle: _menuLabelStyle(),
      ).copyWith(overlayColor: WidgetStateProperty.fromMap(_menuRowTints)),
    ),

    // Menus and flyouts as a light card with a faint edge, so they stand off the bar and the
    // image, and with room around the rows, so the hover stops short of the card's edges
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(_lightColors.surfaceContainerLow),
        shape: const WidgetStatePropertyAll(_overlayShape),
        side: WidgetStatePropertyAll(BorderSide(color: _lightColors.outlineVariant)),
        padding: const WidgetStatePropertyAll(.all(4)),
      ),
    ),
  );
}

/// Material's label style at regular weight, as desktop menus set their items.
///
/// Given whole, because a button's text style replaces its default rather than merging over it.
TextStyle _menuLabelStyle() {
  // The platform defaults to Android if it is not named
  final typography = Typography.material2021(platform: defaultTargetPlatform);
  return typography.englishLike.labelLarge!
      .merge(typography.black.labelLarge)
      .copyWith(fontWeight: .w400);
}

/// What a menu row is tinted with, fainter than Material's.
///
/// A row takes focus when the pointer enters it and then shows its hover tint twice, so hover
/// is half of what a toolbar button shows, and focus, shown alone by keyboard, is all of it.
final _menuRowTints = <WidgetStatesConstraint, Color>{
  WidgetState.pressed: _lightColors.onSurface.withValues(alpha: 0.06),
  WidgetState.hovered: _lightColors.onSurface.withValues(alpha: 0.04),
  WidgetState.focused: _lightColors.onSurface.withValues(alpha: 0.08),
  WidgetState.any: Colors.transparent,
};

/// What an icon button draws its icon in: the accent while selected, faded while disabled, and
/// otherwise the text colour, so the outlined icons read as strongly as the labels.
final _iconButtonColors = <WidgetStatesConstraint, Color>{
  WidgetState.disabled: _lightColors.onSurface.withValues(alpha: 0.38),
  WidgetState.selected: _lightColors.primary,
  WidgetState.any: _lightColors.onSurface,
};

/// The size of an icon, and the optical size it is drawn for.
const _iconSize = 20.0;

/// The corners of a control.
const _controlShape = RoundedRectangleBorder(borderRadius: .all(.circular(4)));

/// The corners of what floats over the window, rounder than a control's.
const _overlayShape = RoundedRectangleBorder(borderRadius: .all(.circular(8)));

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
