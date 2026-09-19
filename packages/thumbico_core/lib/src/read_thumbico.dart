// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:isolate';

import 'package:path/path.dart' as p;

import 'shell/shell_bitmap.dart';
import 'thumbico_exception.dart';
import 'thumbico_image.dart';
import 'thumbico_info.dart';
import 'thumbico_option.dart';
import 'thumbico_size.dart';
import 'thumbico_source.dart';

// The shell's SIZE fields are 32-bit; a larger value would be truncated silently.
const _maximumDimension = 0x7FFFFFFF;

/// Reads the thumbnail or icon of the shell item at [path], at most [size].
///
/// With [ThumbicoSource.auto] the shell is asked for a thumbnail first; if
/// that fails for any reason other than a missing item, its icon is returned
/// instead and [ThumbicoInfo.isIcon] is true.
///
/// Blocks the calling thread for as long as the shell takes, which can be
/// seconds for a video; GUI callers use [readThumbicoAsync]. Throws
/// [ArgumentError] for an empty path or a dimension outside 1 to 2^31 - 1,
/// and [ThumbicoException] when the shell fails.
ThumbicoImage readThumbico(
  String path,
  ThumbicoSize size, {
  ThumbicoSource source = ThumbicoSource.auto,
  Set<ThumbicoOption> options = const {},
}) {
  validateArguments(path, size);
  final shellPath = normalizeShellPath(path);

  switch (source) {
    case ThumbicoSource.thumbnailOnly:
    case ThumbicoSource.iconOnly:
      return _read(shellPath, size, source, options);
    case ThumbicoSource.auto:
      try {
        return _read(shellPath, size, ThumbicoSource.thumbnailOnly, options);
      } on ThumbicoException catch (e) {
        // A missing item fails the same way again, so only that case is not retried.
        if (e.failure == ThumbicoFailure.itemNotFound) {
          rethrow;
        }
        return _read(shellPath, size, ThumbicoSource.iconOnly, options);
      }
  }
}

/// Runs [readThumbico] in a short-lived isolate and returns its result.
///
/// The isolate enters its own COM apartment, so this is safe to call from a
/// UI isolate. Argument errors are reported before any isolate is spawned.
Future<ThumbicoImage> readThumbicoAsync(
  String path,
  ThumbicoSize size, {
  ThumbicoSource source = ThumbicoSource.auto,
  Set<ThumbicoOption> options = const {},
}) async {
  validateArguments(path, size);
  return Isolate.run(() => readThumbico(path, size, source: source, options: options));
}

/// One shell call for an explicit source; the source says whether it is an icon.
ThumbicoImage _read(
  String shellPath,
  ThumbicoSize size,
  ThumbicoSource source,
  Set<ThumbicoOption> options,
) {
  final bitmap = readShellBitmap(shellPath, size.width, size.height, source, options);
  return ThumbicoImage(
    info: ThumbicoInfo(
      size: ThumbicoSize(bitmap.width, bitmap.height),
      requestedSize: size,
      isIcon: source == ThumbicoSource.iconOnly,
    ),
    pixels: bitmap.pixels,
  );
}

/// Rejects what the shell would reject or silently truncate.
void validateArguments(String path, ThumbicoSize size) {
  if (path.trim().isEmpty) {
    throw ArgumentError.value(path, 'path', 'must not be empty');
  }
  _checkDimension(size.width, 'size.width');
  _checkDimension(size.height, 'size.height');
}

void _checkDimension(int value, String name) {
  if (value < 1 || value > _maximumDimension) {
    throw ArgumentError.value(value, name, 'must be between 1 and $_maximumDimension');
  }
}

/// Makes a filesystem path fully qualified, which the shell parser requires.
/// Shell namespace strings are passed through unchanged. Quotes are dropped,
/// since no path or shell string can hold one and Explorer copies paths in them.
String normalizeShellPath(String path) {
  final trimmed = path.trim().replaceAll('"', '');
  if (trimmed.toLowerCase().startsWith('shell:') || trimmed.startsWith('::')) {
    return trimmed;
  }
  return p.normalize(p.absolute(trimmed));
}
