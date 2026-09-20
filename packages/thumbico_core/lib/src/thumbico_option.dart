// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// Options that shape how the shell renders. Each maps to one SIIGBF flag.
///
/// With no options the shell shrinks the image to fit the requested size while preserving its
/// aspect ratio.
enum ThumbicoOption {
  /// Accept an image larger than requested, leaving any scaling to the caller.
  allowLargerSize,

  /// Return the image only if it is already in memory. Safe on a UI thread.
  inMemoryOnly,

  /// Allow disk access, but only to read an already cached image. Safe on a UI thread.
  inCacheOnly,

  /// Crop the image to a square. Windows 8 and later.
  cropToSquare,

  /// Stretch and crop the image to a 0.7 aspect ratio. Windows 8 and later.
  wideAspect,

  /// For icons, paint the background in the associated app's registered color. Windows 8 and later.
  iconBackground,

  /// Stretch a smaller image up so both dimensions fill the requested size. Windows 8 and later.
  scaleUp,
}
