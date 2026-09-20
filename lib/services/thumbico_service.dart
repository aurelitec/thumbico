// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// Loads thumbnails and icons for display, through thumbico_core.
library;

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show visibleForTesting;

import 'package:thumbico_core/thumbico_core.dart';

/// A thumbnail or icon ready to draw: what the shell said about it, and the Flutter image.
///
/// The caller owns [image] and must dispose it.
typedef LoadedThumbico = ({ThumbicoInfo info, ui.Image image});

/// Reads the thumbnail or icon of the item at [path], at most [size], and decodes it.
///
/// [source] and [options] go to the core unchanged. Runs off the UI isolate and throws what
/// [readThumbicoAsync] throws. The shell's pixel buffer is dropped once the Flutter image is made.
Future<LoadedThumbico> loadThumbico(
  String path,
  ThumbicoSize size, {
  ThumbicoSource source = ThumbicoSource.auto,
  Set<ThumbicoOption> options = const {},
}) async {
  final result = await readThumbicoAsync(path, size, source: source, options: options);
  return (info: result.info, image: await toUiImage(result));
}

/// Converts a shell image to a Flutter image.
///
/// Flutter's raw pixel formats expect premultiplied alpha while the shell hands out straight alpha,
/// so the pixels are premultiplied into a copy first.
@visibleForTesting
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
    image.info.size.width,
    image.info.size.height,
    ui.PixelFormat.bgra8888,
    completer.complete,
  );
  return completer.future;
}
