// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// Shows the Windows open dialogs and returns what the user picked.
///
/// Both dialogs pick file-system items only. Shell items such as This PC are reached by typing
/// their name in the path field.
library;

import 'dart:ffi';

import 'package:filepicker_windows/filepicker_windows.dart';

/// Shows the Open dialog for any file, owned by [owner], and returns its path or null on cancel.
///
/// Blocks until the dialog closes, as a modal dialog should. Call it from the button handler.
String? pickFile(Pointer<Void> owner) {
  final picker = OpenFilePicker()..hWndOwner = owner;
  return picker.getFile()?.path;
}

/// Shows the Select Folder dialog, owned by [owner], and returns its path or null on cancel.
///
/// Blocks until the dialog closes, as a modal dialog should. Call it from the button handler.
String? pickFolder(Pointer<Void> owner) {
  final picker = DirectoryPicker()..hWndOwner = owner;
  return picker.getDirectory()?.path;
}
