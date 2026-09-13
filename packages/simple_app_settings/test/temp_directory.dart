// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:io';

import 'package:test/test.dart';

/// A fresh temporary directory, deleted with everything in it when the test ends.
Directory tempDirectory() {
  final directory = Directory.systemTemp.createTempSync('simple_app_settings_');
  addTearDown(() => directory.deleteSync(recursive: true));
  return directory;
}
