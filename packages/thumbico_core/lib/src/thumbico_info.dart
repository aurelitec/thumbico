// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'thumbico_size.dart';

/// What the shell said about a thumbnail or icon, apart from its pixels.
///
/// Small enough to keep around after the pixels are gone.
final class const ThumbicoInfo({
  /// The size the shell produced, which is often not the size requested.
  required final ThumbicoSize size,

  /// The size the shell was asked for, which it treats as an upper bound.
  required final ThumbicoSize requestedSize,

  /// True when the shell returned an icon rather than a thumbnail.
  required final bool isIcon,
}) {
  @override
  bool operator ==(Object other) =>
      other is ThumbicoInfo &&
      other.size == size &&
      other.requestedSize == requestedSize &&
      other.isIcon == isIcon;

  @override
  int get hashCode => Object.hash(size, requestedSize, isIcon);

  @override
  String toString() => '$size, requested $requestedSize, ${isIcon ? 'icon' : 'thumbnail'}';
}
