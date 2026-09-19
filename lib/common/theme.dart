// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:material_ui/material_ui.dart';

/// The application theme for [brightness], shared by every window.
///
/// One builder for the light and the dark theme, so that the two differ in their colours and in
/// nothing else. A window gives its app both, and the app follows the Windows setting.
ThemeData appTheme([Brightness brightness = .light]) {
  final colors = _colors(brightness);
  final isDark = brightness == .dark;

  return ThemeData(
    colorScheme: colors,

    // Material's desktop defaults, stated so that a test, which counts as a touch platform,
    // measures the same sizes as the app
    visualDensity: .compact,
    materialTapTargetSize: .shrinkWrap,

    // A press darkens the control, as on Windows, with no ripple spreading from the pointer
    splashFactory: NoSplash.splashFactory,

    // Icons at the smallest size the symbols are designed for, in the shape drawn for that size
    iconTheme: const IconThemeData(size: _iconSize, opticalSize: _iconSize),

    // Small corners on what Material draws as a circle or a pill, and icons in the text colour.
    // An icon button sizes its own icon, so the size is repeated here. Its tints are stated
    // too: left to Material they came out black in either theme, and on a dark bar a black
    // hover cannot be seen.
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(shape: _controlShape, iconSize: _iconSize).copyWith(
        foregroundColor: WidgetStateProperty.fromMap(_iconButtonColors(colors)),
        overlayColor: WidgetStateProperty.fromMap(_iconButtonTints(colors)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(shape: _controlShape)),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(shape: _controlShape),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(shape: _controlShape)),

    // Fields as Windows draws them: the fill shows the field on the bar, white on the light
    // grey one and a lighter grey on the dark one, and the outline stays faint until the field
    // has focus
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: isDark ? colors.surfaceContainerHigh : colors.surface,
      // Fainter than Material's, which greys the fill down to the bar's own colour
      hoverColor: colors.onSurface.withValues(alpha: 0.03),
      border: const OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
    ),

    // A mark on a button states a fact, so it takes the accent rather than the error red
    badgeTheme: BadgeThemeData(backgroundColor: colors.primary),

    // Menu rows with a rounded hover. A menu row sizes and colours its own icon, as an icon
    // button does, so both are repeated here to match the toolbar.
    menuButtonTheme: MenuButtonThemeData(
      style: MenuItemButton.styleFrom(
        shape: _controlShape,
        iconSize: _iconSize,
        iconColor: colors.onSurface,
        disabledIconColor: colors.onSurface.withValues(alpha: 0.38),
        textStyle: _menuLabelStyle(brightness),
      ).copyWith(overlayColor: WidgetStateProperty.fromMap(_menuRowTints(colors))),
    ),

    // In the dark theme a tooltip is the menus' dark card with their faint edge; Material
    // inverts it to a white box there, a glare spot in a dark window. The light theme keeps
    // Material's own.
    tooltipTheme: isDark
        ? TooltipThemeData(
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              border: Border.all(color: colors.outlineVariant),
              borderRadius: const BorderRadius.all(.circular(4)),
            ),
            textStyle: TextStyle(color: colors.onSurface),
          )
        : null,

    // Menus and flyouts as a light card with a faint edge, so they stand off the bar and the
    // image, and with room around the rows, so the hover stops short of the card's edges
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(colors.surfaceContainerLow),
        shape: const WidgetStatePropertyAll(_overlayShape),
        side: WidgetStatePropertyAll(BorderSide(color: colors.outlineVariant)),
        // Raised further than Material's menu, for a wider and softer shadow
        elevation: const WidgetStatePropertyAll(8),
        padding: const WidgetStatePropertyAll(.all(4)),
      ),
    ),
  );
}

/// Material's label style at regular weight, as desktop menus set their items.
///
/// Given whole, because a button's text style replaces its default rather than merging over it.
TextStyle _menuLabelStyle(Brightness brightness) {
  // The platform defaults to Android if it is not named
  final typography = Typography.material2021(platform: defaultTargetPlatform);
  // The black set is the one for a light theme, and the white set for a dark one
  final fonts = brightness == .dark ? typography.white : typography.black;
  return typography.englishLike.labelLarge!.merge(fonts.labelLarge).copyWith(fontWeight: .w400);
}

/// What a menu row is tinted with, fainter than Material's.
///
/// A row takes focus when the pointer enters it and then shows its hover tint twice, so hover
/// is half of what a toolbar button shows, and focus, shown alone by keyboard, is all of it.
Map<WidgetStatesConstraint, Color> _menuRowTints(ColorScheme colors) => {
  WidgetState.pressed: colors.onSurface.withValues(alpha: 0.06),
  WidgetState.hovered: colors.onSurface.withValues(alpha: 0.04),
  WidgetState.focused: colors.onSurface.withValues(alpha: 0.08),
  WidgetState.any: Colors.transparent,
};

/// What an icon button is tinted with: Material's own strengths, from the text colour, so that
/// the tint darkens a light bar and lightens a dark one, and matches a menu row's.
Map<WidgetStatesConstraint, Color> _iconButtonTints(ColorScheme colors) => {
  WidgetState.pressed: colors.onSurface.withValues(alpha: 0.1),
  WidgetState.hovered: colors.onSurface.withValues(alpha: 0.08),
  WidgetState.focused: colors.onSurface.withValues(alpha: 0.1),
  WidgetState.any: Colors.transparent,
};

/// What an icon button draws its icon in: the accent while selected, faded while disabled, and
/// otherwise the text colour, so the outlined icons read as strongly as the labels.
Map<WidgetStatesConstraint, Color> _iconButtonColors(ColorScheme colors) => {
  WidgetState.disabled: colors.onSurface.withValues(alpha: 0.38),
  WidgetState.selected: colors.primary,
  WidgetState.any: colors.onSurface,
};

/// The size of an icon, and the optical size it is drawn for.
const _iconSize = 20.0;

/// The corners of a control.
const _controlShape = RoundedRectangleBorder(borderRadius: .all(.circular(4)));

/// The corners of what floats over the window, rounder than a control's.
const _overlayShape = RoundedRectangleBorder(borderRadius: .all(.circular(8)));

/// The colours of the light or the dark theme, each role given as its light and its dark value.
///
/// Windows 11's greys, with a green from the app icon as the only colour. Written out rather
/// than seeded: a seed tints every surface, and the chrome must stay neutral beside whatever
/// image is shown. Roles left out fall back to the ones given here.
ColorScheme _colors(Brightness brightness) {
  // Every value is a colour literal, light first, so that the editor previews it
  final isLight = brightness == .light;

  // The icon's ear green, the lightest of its tones that carries white text; on dark its face
  // green, which has the contrast there that it lacks on white, under near-black text
  final accent = isLight ? const Color(0xFF2E8F2B) : const Color(0xFF4CC23A);
  final onAccent = isLight ? const Color(0xFFFFFFFF) : const Color(0xFF0A1F0A);

  return ColorScheme(
    brightness: brightness,

    // The accent, for whatever is on, selected, or focused. The secondary roles carry it too,
    // since the segmented button and the tonal filled button colour themselves from those.
    primary: accent,
    onPrimary: onAccent,
    secondary: accent,
    onSecondary: onAccent,
    secondaryContainer: accent,
    onSecondaryContainer: onAccent,
    // Must differ from the accent: a switch that is on draws its knob in this colour under the
    // pointer
    primaryContainer: isLight ? const Color(0xFFDCF3D9) : const Color(0xFF1B5E20),
    onPrimaryContainer: isLight ? const Color(0xFF1B5E20) : const Color(0xFFDCF3D9),

    // Windows' own critical red, which carries white text in either theme: the status bar
    // while it reports a problem
    error: const Color(0xFFC42B1C),
    onError: const Color(0xFFFFFFFF),

    // The canvas, the quietest surface in either theme, and the text on every surface
    surface: isLight ? const Color(0xFFFFFFFF) : const Color(0xFF161616),
    onSurface: isLight ? const Color(0xFF1B1B1B) : const Color(0xFFFFFFFF),
    onSurfaceVariant: isLight ? const Color(0xFF5D5D5D) : const Color(0xFFC5C5C5),

    // The menus and flyouts, the bars, and the dark theme's field fill, in steps of one grey
    surfaceContainerLowest: isLight ? const Color(0xFFFFFFFF) : const Color(0xFF161616),
    surfaceContainerLow: isLight ? const Color(0xFFF9F9F9) : const Color(0xFF2C2C2C),
    surfaceContainer: isLight ? const Color(0xFFF3F3F3) : const Color(0xFF202020),
    surfaceContainerHigh: isLight ? const Color(0xFFEBEBEB) : const Color(0xFF2D2D2D),
    surfaceContainerHighest: isLight ? const Color(0xFFE5E5E5) : const Color(0xFF343434),
    surfaceDim: isLight ? const Color(0xFFE5E5E5) : const Color(0xFF161616),
    surfaceBright: isLight ? const Color(0xFFFFFFFF) : const Color(0xFF343434),

    // Field and control borders, then the fainter dividers
    outline: isLight ? const Color(0xFF8D8D8D) : const Color(0xFF8A8A8A),
    outlineVariant: isLight ? const Color(0xFFD1D1D1) : const Color(0xFF3A3A3A),

    // Raised surfaces keep their own grey instead of taking a wash of the accent
    surfaceTint: const Color(0x00000000),
  );
}
