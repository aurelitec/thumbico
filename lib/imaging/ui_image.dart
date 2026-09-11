// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:thumbico_core/thumbico_core.dart';

/// Converts a shell image to a Flutter image.
///
/// Flutter's raw pixel formats expect premultiplied alpha while the shell
/// hands out straight alpha, so the pixels are premultiplied into a copy first.
Future<ui.Image> toUiImage(ThumbicoImage image) {
  final bytes = Uint8List.fromList(image.pixels);
  for (var i = 0; i < bytes.length; i += 4) {
    final alpha = bytes[i + 3];
    if (alpha == 255) {
      continue;
    }
    bytes[i] = (bytes[i] * alpha + 127) ~/ 255;
    bytes[i + 1] = (bytes[i + 1] * alpha + 127) ~/ 255;
    bytes[i + 2] = (bytes[i + 2] * alpha + 127) ~/ 255;
  }

  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    bytes,
    image.width,
    image.height,
    ui.PixelFormat.bgra8888,
    completer.complete,
  );
  return completer.future;
}
