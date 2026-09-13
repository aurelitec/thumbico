// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

// The windowing API is still internal, so opening a window needs implementation imports.
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: implementation_imports

import 'package:flutter/src/widgets/_window.dart';

import 'package:material_ui/material_ui.dart';
import 'package:simple_app_settings/simple_app_settings.dart';

import 'common/strings.dart' as strings;
import 'windows/main_window.dart';

void main() {
  // Settings read the file the first time one is touched, so the store must exist before any window.
  SettingsStore.shared = SettingsStore.forApp(
    company: strings.companyName,
    product: strings.appName,
    onSaveError: (error, stackTrace) => debugPrint('Could not save the settings: $error'),
  );
  WidgetsFlutterBinding.ensureInitialized();
  runWidget(
    WindowManager(
      initialWindows: [
        MainWindow.windowEntry(),
      ],
    ),
  );
}
