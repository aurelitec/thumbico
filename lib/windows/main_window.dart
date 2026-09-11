// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

// The windowing API is still internal, so opening a window needs implementation imports.
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: implementation_imports

import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/_window.dart';

import 'package:material_ui/material_ui.dart';

import '../common/strings.dart' as strings;
import '../common/theme.dart';

/// The main window of the application.
class const MainWindow({super.key}) extends StatelessWidget {
  // Constructing the controller is what creates the native window
  static final _controller = WindowController(
    size: const Size(600, 400),
    title: strings.mainWindowTitle,
    delegate: _MainWindowControllerDelegate(),
  );

  /// Returns a [WindowEntry] for the main window. Call before `runWidget`.
  static WindowEntry windowEntry() {
    // Each window gets its own MaterialApp, which is what gives text fields
    // their localizations and tooltips their overlay.
    return WindowEntry(
      controller: _controller,
      builder: (context) => MaterialApp(
        title: strings.appName,
        theme: appTheme(),
        home: const MainWindow(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Material(
      child: Center(
        child: Text(strings.appName),
      ),
    );
  }
}

class _MainWindowControllerDelegate with WindowControllerDelegate {
  @override
  void onWindowDestroyed() {
    super.onWindowDestroyed();
    ServicesBinding.instance.exitApplication(AppExitType.required);
  }
}
