// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:typed_data';

import 'thumbico_size.dart';

/// The thumbnail or icon of a shell item, as the shell produced it.
final class const ThumbicoImage({
  /// The width the shell produced, which is often not the width requested.
  required final int width,

  /// The height the shell produced, which is often not the height requested.
  required final int height,

  required final ThumbicoSize requestedSize,

  /// True when the shell returned an icon rather than a thumbnail.
  required final bool isIcon,

  /// Straight (non-premultiplied) alpha, BGRA byte order, four bytes per
  /// pixel, rows top-down with no padding, so the length is
  /// `width * height * 4`.
  required final Uint8List pixels,
}) {
  int get rowStride => width * 4;
}
