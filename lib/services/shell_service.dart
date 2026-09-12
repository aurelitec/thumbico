// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// The application's access to the Windows shell, through thumbico_core.
library;

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:thumbico_core/thumbico_core.dart';

/// What the shell said about an item, together with the Flutter image drawn from it.
///
/// The caller owns [image] and must dispose it.
typedef ShellImage = ({ThumbicoInfo info, ui.Image image});

/// Asks the shell for the thumbnail or icon of the item at [path], at most [size].
///
/// Runs off the UI isolate and throws what [readThumbicoAsync] throws. The
/// shell's pixel buffer is dropped once the Flutter image has been made.
Future<ShellImage> readShellImage(String path, ThumbicoSize size) async {
  final result = await readThumbicoAsync(path, size);
  return (info: result.info, image: await toUiImage(result));
}

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
    image.info.size.width,
    image.info.size.height,
    ui.PixelFormat.bgra8888,
    completer.complete,
  );
  return completer.future;
}
