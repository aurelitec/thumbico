// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// Saves the shown image to a file in the format its name asks for.
library;

import 'dart:io';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import 'package:thumbico_core/thumbico_core.dart';

import '../imaging/image_conversion.dart';

/// The largest width or height an ICO entry can record.
const icoMaximumDimension = 256;

// The formats whose readers honour an alpha channel; every other format is flattened.
const _transparentExtensions = {'.png', '.ico'};

// Characters Windows does not allow in a file name.
final _invalidNameCharacters = RegExp(r'[<>:"/\\|?*\x00-\x1F]');

/// What came of a save.
sealed class const SaveResult();

/// The file was written.
final class const Saved() extends SaveResult;

/// The file name's extension names no format the app can write.
final class const UnknownFormat() extends SaveResult;

/// The image is wider or taller than an ICO entry can hold.
final class const TooLargeForIco() extends SaveResult;

/// The file could not be written.
final class const WriteFailed(
  /// The operating system's message.
  final String reason,
) extends SaveResult;

/// The name the save dialog opens with: the item's own name, the app's, and [size].
///
/// The item's name is dropped when the path has none, such as a drive root, or when it
/// holds characters a file name cannot, such as a shell string.
String suggestedFileName(String itemPath, ThumbicoSize size) {
  final name = p.basenameWithoutExtension(itemPath.trim());
  final sizeText = '${size.width}x${size.height}';
  if (name.isEmpty || name.contains(_invalidNameCharacters)) {
    return 'thumbico_$sizeText';
  }
  return '${name}_thumbico_$sizeText';
}

/// Writes [image] to [path] in the format the extension names.
///
/// PNG and ICO keep transparency; every other format is flattened onto [background]
/// first. Encoding runs off the UI isolate. Nothing is written when the result is not
/// [Saved].
Future<SaveResult> saveImage(ui.Image image, String path, ui.Color background) async {
  final extension = p.extension(path).toLowerCase();
  if (img.findEncoderForNamedImage(path) == null) {
    return const UnknownFormat();
  }
  if (extension == '.ico' &&
      (image.width > icoMaximumDimension || image.height > icoMaximumDimension)) {
    return const TooLargeForIco();
  }

  final source = await toImage(image);
  final keepsTransparency = _transparentExtensions.contains(extension);
  final argb = background.toARGB32();
  final bytes = await Isolate.run(
    () => img.encodeNamedImage(path, keepsTransparency ? source : flatten(source, argb))!,
  );

  try {
    await File(path).writeAsBytes(bytes, flush: true);
    return const Saved();
  } on FileSystemException catch (e) {
    return WriteFailed(e.osError?.message ?? e.message);
  }
}
