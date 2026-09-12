// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:thumbico/services/shell_service.dart';
import 'package:thumbico_core/thumbico_core.dart';

void main() {
  test('toUiImage premultiplies straight alpha and keeps opaque pixels as they are', () async {
    // Two BGRA pixels: one opaque, one half transparent.
    final pixels = Uint8List.fromList([10, 20, 30, 255, 200, 100, 50, 128]);
    final source = ThumbicoImage(
      info: const ThumbicoInfo(
        size: ThumbicoSize(2, 1),
        requestedSize: ThumbicoSize.square(2),
        isIcon: false,
      ),
      pixels: pixels,
    );

    final image = await toUiImage(source);
    addTearDown(image.dispose);
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

    expect(image.width, 2);
    expect(image.height, 1);
    expect(data!.buffer.asUint8List(), [30, 20, 10, 255, 25, 50, 100, 128]);
    expect(pixels, [10, 20, 30, 255, 200, 100, 50, 128], reason: 'the source is not modified');
  });

  test('readShellImage returns the shell facts and the decoded image at that size', () async {
    final directory = Directory.systemTemp.createTempSync('thumbico_app_');
    addTearDown(() => directory.deleteSync(recursive: true));
    final path = '${directory.path}${Platform.pathSeparator}sample.txt';
    File(path).writeAsStringSync('hello from the tests\n');

    final shellImage = await readShellImage(path, const ThumbicoSize.square(32));
    addTearDown(shellImage.image.dispose);

    expect(shellImage.info.isIcon, isTrue);
    expect(shellImage.info.requestedSize, const ThumbicoSize.square(32));
    expect(shellImage.image.width, shellImage.info.size.width);
    expect(shellImage.image.height, shellImage.info.size.height);
  });

  test('readShellImage passes the shell failure through', () async {
    expect(
      () => readShellImage(r'C:\does\not\exist.txt', const ThumbicoSize.square(32)),
      throwsA(isA<ThumbicoException>()),
    );
  });
}
