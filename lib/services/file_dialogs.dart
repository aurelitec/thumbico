// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// Shows the Windows file dialogs and returns what the user picked.
///
/// The open dialogs pick file-system items only. Shell items such as This PC are reached by
/// typing their name in the path field.
library;

import 'dart:ffi';

import 'package:filepicker_windows/filepicker_windows.dart';

import '../common/strings.dart' as strings;

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

/// Shows the Save as dialog, owned by [owner]; completes with the chosen path or null on cancel.
///
/// Opens with [suggestedName] in the name field. A name typed without an extension gets the
/// selected type's, and the dialog itself asks before an existing file is replaced. Called from a
/// menu item, so the dialog is shown from a message-loop task of its own and never inside a frame.
Future<String?> pickSavePath(Pointer<Void> owner, String suggestedName) {
  return Future(() {
    final picker = SaveFilePicker()
      ..hWndOwner = owner
      ..fileName = suggestedName
      ..defaultExtension = 'png'
      ..filterSpecification = strings.saveFilters;
    return picker.getFile()?.path;
  });
}
