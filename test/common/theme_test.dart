// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:thumbico/common/theme.dart';

void main() {
  final colors = appTheme().colorScheme;

  test('the canvas is pure white', () {
    expect(colors.surface, const Color(0xFFFFFFFF));
  });

  test('no surface carries a tint', () {
    final surfaces = [
      colors.surface,
      colors.surfaceContainerLowest,
      colors.surfaceContainerLow,
      colors.surfaceContainer,
      colors.surfaceContainerHigh,
      colors.surfaceContainerHighest,
      colors.surfaceDim,
      colors.surfaceBright,
    ];
    for (final surface in surfaces) {
      expect(
        surface.r == surface.g && surface.g == surface.b,
        isTrue,
        reason: '$surface is tinted',
      );
    }
  });

  test('nothing ripples', () {
    expect(appTheme().splashFactory, NoSplash.splashFactory);
  });

  test('buttons and segments have square corners instead of pills and circles', () {
    final theme = appTheme();
    final shapes = [
      theme.iconButtonTheme.style?.shape?.resolve({}),
      theme.filledButtonTheme.style?.shape?.resolve({}),
      theme.segmentedButtonTheme.style?.shape?.resolve({}),
    ];
    for (final shape in shapes) {
      expect(shape, isA<RoundedRectangleBorder>());
    }
  });
}
