// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:typed_data';

import 'thumbico_info.dart';

/// The thumbnail or icon of a shell item, as the shell produced it.
final class const ThumbicoImage({
  /// What the shell said about the image, which can outlive [pixels].
  required final ThumbicoInfo info,

  /// Straight (non-premultiplied) alpha, BGRA byte order, four bytes per pixel, rows top-down with
  /// no padding, so the length is `info.size.width * info.size.height * 4`.
  required final Uint8List pixels,
});
