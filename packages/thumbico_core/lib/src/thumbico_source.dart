// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// Which kind of image to ask the shell for.
enum ThumbicoSource {
  /// The thumbnail if the item has one, otherwise its icon.
  auto,

  /// Only a thumbnail. Fails for items that have none.
  thumbnailOnly,

  /// Only an icon, never a thumbnail.
  iconOnly,
}
