// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

// The windowing feature flag is internal, and tests must switch it off.
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: implementation_imports

import 'package:flutter/src/foundation/_features.dart';
import 'package:material_ui/material_ui.dart';
import 'package:thumbico/common/theme.dart';

/// Call first in a widget test's `main`, before any `testWidgets`.
///
/// `flutter test` cannot create the native windowing owner that the test binding would otherwise
/// construct when the windowing feature is on (flutter/flutter#178706). The widgets under test do
/// not need one.
void disableWindowingForTests() {
  isWindowingEnabled = false;
}

/// Wraps a widget under test in what a window gives it: a MaterialApp under the application
/// theme, and a Material.
///
/// The theme matters for sizes: under Material's default a test counts as a touch platform and
/// pads every button, so a row that fits in the app overflows in the test.
Widget host(Widget child) => MaterialApp(
  theme: appTheme(),
  home: Material(child: child),
);
