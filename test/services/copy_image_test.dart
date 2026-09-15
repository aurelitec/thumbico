// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

// These tests write to the machine's real clipboard; there is no other one to write to.

import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thumbico/services/copy_image.dart';
import 'package:win32/win32.dart' show CF_DIBV5;
import 'package:win32_clipboard/win32_clipboard.dart';

void main() {
  const dibV5 = ClipboardFormat(CF_DIBV5, 'CF_DIBV5');
  const white = ui.Color(0xFFFFFFFF);

  /// Three premultiplied RGBA pixels: opaque red, fully transparent, half-transparent blue.
  Future<ui.Image> threePixels() {
    final bytes = Uint8List.fromList([255, 0, 0, 255, 0, 0, 0, 0, 0, 0, 128, 128]);
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(bytes, 3, 1, ui.PixelFormat.rgba8888, completer.complete);
    return completer.future;
  }

  /// Reads the DIBv5 back from the clipboard as bytes.
  Uint8List readBack() {
    final data = Clipboard.getData(dibV5);
    expect(data, isA<PointerData>());
    final pointer = (data! as PointerData).pointer;
    final bytes = Uint8List.fromList(pointer.asTypedList((data as PointerData).lengthInBytes));
    malloc.free(pointer);
    return bytes;
  }

  test('copyImage puts one DIBv5 on the clipboard with a 124-byte header', () async {
    final image = await threePixels();
    addTearDown(image.dispose);

    expect(await copyImage(image, white), isTrue);

    final bytes = readBack();
    final header = ByteData.sublistView(bytes);
    expect(bytes.length, 124 + 3 * 4);
    expect(header.getUint32(0, Endian.little), 124, reason: 'header size');
    expect(header.getInt32(4, Endian.little), 3, reason: 'width');
    expect(header.getInt32(8, Endian.little), 1, reason: 'height');
    expect(header.getUint16(14, Endian.little), 32, reason: 'bits per pixel');
    expect(header.getUint32(52, Endian.little), 0xFF000000, reason: 'alpha mask');
    expect(Clipboard.formats.map((f) => f.id), isNot(contains(0xC13F)), reason: 'no PNG');
  });

  test('copyImage flattens transparency onto the background and keeps opaque pixels', () async {
    final image = await threePixels();
    addTearDown(image.dispose);

    await copyImage(image, white);

    final pixels = readBack().sublist(124);
    expect(pixels.sublist(0, 4), [0, 0, 255, 255], reason: 'opaque red stays red, as BGRA');
    expect(pixels.sublist(4, 8), [255, 255, 255, 255], reason: 'transparent becomes white');
    final blended = pixels.sublist(8, 12);
    expect(blended[0], 255, reason: 'blue stays full');
    expect(blended[1], inInclusiveRange(120, 135), reason: 'green is half white');
    expect(blended[2], inInclusiveRange(120, 135), reason: 'red is half white');
    expect(blended[3], 255, reason: 'the result is opaque');
  });
}
