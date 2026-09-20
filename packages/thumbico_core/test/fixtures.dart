// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:thumbico_core/thumbico_core.dart';

/// Test files written into a fresh temporary directory, so the shell's thumbnail and icon caches
/// never hand back stale content.
final class Fixtures {
  new _(this.directory);

  /// The directory the files were written into.
  final Directory directory;

  /// A 400x300 image with the layout described on [layoutImage].
  late final String png = _write('sample.png', img.encodePng(layoutImage(400, 300)));

  /// A 32x32 icon with the same layout, for asserting icon orientation.
  late final String ico = _write('sample.ico', img.encodeIco(layoutImage(32, 32)));

  /// A text file: no thumbnail handler, so the shell falls back to its icon.
  late final String text = _write('sample.txt', utf8.encode('hello from the tests\n'));

  static Fixtures create() => Fixtures._(Directory.systemTemp.createTempSync('thumbico_core_'));

  void dispose() => directory.deleteSync(recursive: true);

  String _write(String name, List<int> bytes) {
    final path = p.join(directory.path, name);
    File(path).writeAsBytesSync(bytes);
    return path;
  }
}

/// Builds an image whose top and bottom, left and right differ, so a flipped or mirrored result is
/// caught: red top half, blue bottom half, a half-transparent green band over the left 15 percent,
/// and a fully transparent band over the right 25 percent.
img.Image layoutImage(int width, int height) {
  final image = img.Image(width: width, height: height, numChannels: 4);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      if (x >= width * 3 ~/ 4) {
        image.setPixelRgba(x, y, 0, 0, 0, 0);
      } else if (x < width * 15 ~/ 100) {
        image.setPixelRgba(x, y, 0, 200, 0, 128);
      } else if (y < height ~/ 2) {
        image.setPixelRgba(x, y, 220, 0, 0, 255);
      } else {
        image.setPixelRgba(x, y, 0, 0, 220, 255);
      }
    }
  }
  return image;
}

/// The pixel at [x], [y] as red, green, blue, alpha.
(int, int, int, int) pixelAt(ThumbicoImage image, int x, int y) {
  final i = (y * image.info.size.width + x) * 4;
  final pixels = image.pixels;
  return (pixels[i + 2], pixels[i + 1], pixels[i], pixels[i + 3]);
}
