// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:thumbico/imaging/image_conversion.dart';

void main() {
  /// Three premultiplied RGBA pixels: opaque red, fully transparent, half-transparent blue.
  Future<ui.Image> threePixels() {
    final bytes = Uint8List.fromList([255, 0, 0, 255, 0, 0, 0, 0, 0, 0, 128, 128]);
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(bytes, 3, 1, ui.PixelFormat.rgba8888, completer.complete);
    return completer.future;
  }

  test('toImage gives a four-channel image with straight alpha', () async {
    final source = await threePixels();
    addTearDown(source.dispose);

    final image = await toImage(source);

    expect(image.width, 3);
    expect(image.height, 1);
    expect(image.numChannels, 4);
    expect(image.getPixel(0, 0).toList(), [255, 0, 0, 255]);
    expect(image.getPixel(1, 0).a, 0);
    expect(image.getPixel(2, 0).a, 128);
    expect(image.getPixel(2, 0).b, 255, reason: 'straight alpha, not premultiplied');
  });

  test('flatten composites onto an opaque colour', () async {
    final image = img.Image(width: 3, height: 1, numChannels: 4)
      ..setPixelRgba(0, 0, 255, 0, 0, 255)
      ..setPixelRgba(1, 0, 0, 0, 0, 0)
      ..setPixelRgba(2, 0, 0, 0, 255, 128);

    final flat = flatten(image, 0xFFFFFFFF);

    expect(flat.getPixel(0, 0).toList(), [255, 0, 0, 255], reason: 'opaque stays');
    expect(flat.getPixel(1, 0).toList(), [255, 255, 255, 255], reason: 'transparent becomes white');
    final blended = flat.getPixel(2, 0);
    expect(blended.r, inInclusiveRange(120, 135));
    expect(blended.g, inInclusiveRange(120, 135));
    expect(blended.b, 255);
    expect(blended.a, 255);
    expect(image.getPixel(1, 0).a, 0, reason: 'the source is not modified');
  });
}
