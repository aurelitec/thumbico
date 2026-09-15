// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// Turns the shown Flutter image into an image the `image` package can encode, and flattens it.
library;

import 'dart:ui' as ui;

import 'package:image/image.dart' as img;

/// Reads [image] back from Flutter as a four-channel, straight-alpha image.
///
/// Flutter un-premultiplies on the way out, so translucent pixels can differ from the shell's
/// by a unit or two; opaque and fully transparent pixels are exact.
Future<img.Image> toImage(ui.Image image) async {
  final rgba = await image.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
  if (rgba == null) {
    throw StateError('Flutter could not read the image back');
  }
  return img.Image.fromBytes(
    width: image.width,
    height: image.height,
    bytes: rgba.buffer,
    numChannels: 4,
  );
}

/// Composites [image] onto the opaque colour [backgroundArgb] and returns the result.
///
/// The result has four channels with every alpha at 255, so any encoder writes it as an
/// ordinary opaque picture. [image] is left as it is.
img.Image flatten(img.Image image, int backgroundArgb) {
  final flat = img.Image(width: image.width, height: image.height, numChannels: 4)
    ..clear(
      img.ColorRgba8(
        (backgroundArgb >> 16) & 0xFF,
        (backgroundArgb >> 8) & 0xFF,
        backgroundArgb & 0xFF,
        255,
      ),
    );
  return img.compositeImage(flat, image);
}
