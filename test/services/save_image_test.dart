// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:thumbico/services/save_image.dart';
import 'package:thumbico_core/thumbico_core.dart';

void main() {
  const white = ui.Color(0xFFFFFFFF);

  /// Three premultiplied RGBA pixels: opaque red, fully transparent, half-transparent blue.
  Future<ui.Image> threePixels() => _image(3, [255, 0, 0, 255, 0, 0, 0, 0, 0, 0, 128, 128]);

  late Directory directory;
  setUp(() {
    directory = Directory.systemTemp.createTempSync('thumbico_save_');
    addTearDown(() => directory.deleteSync(recursive: true));
  });
  String path(String name) => '${directory.path}${Platform.pathSeparator}$name';

  group('suggestedFileName', () {
    const size = ThumbicoSize(256, 192);

    test('is the item name without its extension, the app name, and the size', () {
      expect(suggestedFileName(r'C:\Windows\notepad.exe', size), 'notepad_thumbico_256x192');
      expect(suggestedFileName(r'C:\Users\me\Pictures', size), 'Pictures_thumbico_256x192');
    });

    test('falls back to the app name when the path has no usable name', () {
      expect(suggestedFileName(r'C:\', size), 'thumbico_256x192');
      expect(suggestedFileName('shell:RecycleBinFolder', size), 'thumbico_256x192');
      expect(
        suggestedFileName('::{20D04FE0-3AEA-1069-A2D8-08002B30309D}', size),
        'thumbico_256x192',
      );
    });
  });

  group('saveImage', () {
    test('writes a PNG that keeps transparency', () async {
      final image = await threePixels();
      addTearDown(image.dispose);
      final file = path('out.png');

      final result = await saveImage(image, file, white);

      expect(result, const Saved());
      final saved = img.decodePng(File(file).readAsBytesSync())!;
      expect(saved.getPixel(1, 0).a, 0);
      expect(saved.getPixel(2, 0).a, 128);
    });

    test('writes a BMP flattened onto the background', () async {
      final image = await threePixels();
      addTearDown(image.dispose);
      final file = path('out.bmp');

      final result = await saveImage(image, file, white);

      expect(result, const Saved());
      final saved = img.decodeBmp(File(file).readAsBytesSync())!;
      expect(saved.getPixel(1, 0).toList().take(3), [255, 255, 255]);
    });

    test('writes a single-entry ICO that keeps transparency', () async {
      final image = await threePixels();
      addTearDown(image.dispose);
      final file = path('out.ico');

      final result = await saveImage(image, file, white);

      expect(result, const Saved());
      final saved = img.decodeIco(File(file).readAsBytesSync())!;
      expect(saved.width, 3);
      expect(saved.getPixel(1, 0).a, 0);
    });

    test('refuses an ICO larger than 256 pixels', () async {
      final image = await _image(257, Uint8List(257 * 4));
      addTearDown(image.dispose);
      final file = path('wide.ico');

      final result = await saveImage(image, file, white);

      expect(result, const TooLargeForIco());
      expect(File(file).existsSync(), isFalse);
    });

    test('refuses an extension it cannot encode', () async {
      final image = await threePixels();
      addTearDown(image.dispose);
      final file = path('out.txt');

      final result = await saveImage(image, file, white);

      expect(result, const UnknownFormat());
      expect(File(file).existsSync(), isFalse);
    });

    test('reports a write failure with the reason', () async {
      final image = await threePixels();
      addTearDown(image.dispose);
      final file = path('missing${Platform.pathSeparator}out.png');

      final result = await saveImage(image, file, white);

      expect(result, isA<WriteFailed>().having((r) => r.reason, 'reason', isNotEmpty));
    });
  });
}

Future<ui.Image> _image(int width, List<int> rgba) {
  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    Uint8List.fromList(rgba),
    width,
    1,
    ui.PixelFormat.rgba8888,
    completer.complete,
  );
  return completer.future;
}
