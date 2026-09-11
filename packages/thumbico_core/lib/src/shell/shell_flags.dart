// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:win32/win32.dart';

import '../thumbico_option.dart';
import '../thumbico_source.dart';

/// The SIIGBF flag each option stands for.
SIIGBF shellFlagOf(ThumbicoOption option) => switch (option) {
  ThumbicoOption.allowLargerSize => SIIGBF_BIGGERSIZEOK,
  ThumbicoOption.inMemoryOnly => SIIGBF_MEMORYONLY,
  ThumbicoOption.inCacheOnly => SIIGBF_INCACHEONLY,
  ThumbicoOption.cropToSquare => SIIGBF_CROPTOSQUARE,
  ThumbicoOption.wideAspect => SIIGBF_WIDETHUMBNAILS,
  ThumbicoOption.iconBackground => SIIGBF_ICONBACKGROUND,
  ThumbicoOption.scaleUp => SIIGBF_SCALEUP,
};

/// Combines an explicit source with a set of options into one flags value.
///
/// [source] must be thumbnail-only or icon-only; auto is resolved by the
/// caller into one of those. Resize-to-fit is zero and therefore implicit.
SIIGBF toShellFlags(ThumbicoSource source, Set<ThumbicoOption> options) {
  var flags = switch (source) {
    ThumbicoSource.thumbnailOnly => SIIGBF_THUMBNAILONLY,
    ThumbicoSource.iconOnly => SIIGBF_ICONONLY,
    ThumbicoSource.auto => throw ArgumentError.value(
      source,
      'source',
      'auto must be resolved by the caller',
    ),
  };
  for (final option in options) {
    flags = flags | shellFlagOf(option);
  }
  return flags;
}
