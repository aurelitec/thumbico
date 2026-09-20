// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// Copies the shown image to the Windows clipboard.
library;

import 'dart:ffi';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:ffi/ffi.dart';
import 'package:image/image.dart' as img;
import 'package:win32/win32.dart' show CF_DIBV5;
import 'package:win32_clipboard/win32_clipboard.dart';

import '../imaging/image_conversion.dart';

// A BMP file is a 14-byte file header followed by exactly what CF_DIBV5 holds.
const _bmpFileHeaderLength = 14;

/// The one clipboard format written, every other bitmap form being synthesized from it.
const _dibV5 = ClipboardFormat(CF_DIBV5, 'CF_DIBV5');

/// Puts [image] on the clipboard as an opaque bitmap, flattened onto [background].
///
/// One CF_DIBV5 entry, from which Windows makes the legacy bitmap forms, so every application can
/// paste it. Transparency is not carried; Save As PNG or ICO keeps it. Completes with whether the
/// clipboard took the image. The pixel work runs off the UI isolate, so a large image does not
/// freeze the window.
Future<bool> copyImage(ui.Image image, ui.Color background) async {
  final source = await toImage(image);
  final argb = background.toARGB32();
  final dib = await Isolate.run(
    () => img.encodeBmp(flatten(source, argb)).sublist(_bmpFileHeaderLength),
  );

  return using((arena) {
    final buffer = arena<Uint8>(dib.length)..asTypedList(dib.length).setAll(0, dib);
    return Clipboard.setData(ClipboardData.pointer(buffer, dib.length, _dibV5));
  });
}
