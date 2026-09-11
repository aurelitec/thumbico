// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../thumbico_exception.dart';
import '../thumbico_option.dart';
import '../thumbico_source.dart';
import 'com_apartment.dart';
import 'shell_flags.dart';

/// The pixels of one shell image, in the package's pixel convention.
final class const ShellBitmap({
  required final int width,
  required final int height,
  required final Uint8List pixels,
});

/// Asks the shell for the image of [path] and copies its pixels out.
///
/// [path] must already be fully qualified and [source] must not be auto.
/// Every native resource is released before this returns, on success and on
/// failure alike.
ShellBitmap readShellBitmap(
  String path,
  int width,
  int height,
  ThumbicoSource source,
  Set<ThumbicoOption> options,
) {
  final flags = toShellFlags(source, options);
  return withComApartment(path, () {
    return using((arena) {
      final IShellItemImageFactory factory;
      try {
        factory = SHCreateItemFromParsingName<IShellItemImageFactory>(arena.pcwstr(path), null);
      } on WindowsException catch (e) {
        throw ThumbicoException(
          hresult: e.hr,
          path: path,
          operation: 'SHCreateItemFromParsingName',
        );
      }

      try {
        final size = arena<SIZE>().ref
          ..cx = width
          ..cy = height;

        final HBITMAP bitmap;
        try {
          bitmap = factory.getImage(size, flags);
        } on WindowsException catch (e) {
          throw ThumbicoException(
            hresult: e.hr,
            path: path,
            operation: 'IShellItemImageFactory.GetImage',
          );
        }

        try {
          return _copyPixels(bitmap, path, arena);
        } finally {
          DeleteObject(HGDIOBJ(bitmap));
        }
      } finally {
        factory.release();
      }
    });
  });
}

/// Reads the bitmap top-down at 32 bits per pixel.
///
/// The shell returns icons bottom-up and thumbnails top-down while reporting
/// a positive height for both, so the header cannot tell them apart. Asking
/// GDI for a negative height dictates top-down rows for either kind.
ShellBitmap _copyPixels(HBITMAP bitmap, String path, Arena arena) {
  final info = arena<BITMAP>();
  if (GetObject(HGDIOBJ(bitmap), sizeOf<BITMAP>(), info) == 0) {
    throw _lastError(path, 'GetObject');
  }
  final width = info.ref.bmWidth;
  final height = info.ref.bmHeight.abs();
  final byteCount = width * height * 4;

  final header = arena<BITMAPINFO>();
  header.ref.bmiHeader
    ..biSize = sizeOf<BITMAPINFOHEADER>()
    ..biWidth = width
    ..biHeight = -height
    ..biPlanes = 1
    ..biBitCount = 32
    ..biCompression = BI_RGB;

  final buffer = arena<Uint8>(byteCount);
  final dc = GetDC(null);
  try {
    final copied = GetDIBits(dc, bitmap, 0, height, buffer, header, DIB_RGB_COLORS);
    if (copied != height) {
      throw _lastError(path, 'GetDIBits');
    }
  } finally {
    ReleaseDC(null, dc);
  }

  return ShellBitmap(
    width: width,
    height: height,
    pixels: Uint8List.fromList(buffer.asTypedList(byteCount)),
  );
}

ThumbicoException _lastError(String path, String operation) =>
    ThumbicoException(hresult: GetLastError().toHRESULT(), path: path, operation: operation);
