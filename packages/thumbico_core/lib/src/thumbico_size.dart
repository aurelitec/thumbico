// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// A requested size in pixels, and the text form every frontend parses the same way.
///
/// There is no upper limit here. A maximum is a product decision each frontend
/// applies before calling the core.
final class const ThumbicoSize(final int width, final int height) {
  const new square(int side) : this(side, side);

  // The separator may be x, X, or the multiplication sign.
  static final _separator = RegExp('[xX\u00D7]');
  static final _digits = RegExp(r'^[0-9]+$');

  /// Parses a single number as a square, or two numbers separated by an x.
  ///
  /// Whitespace around and between the parts is ignored. Only bare digits are
  /// accepted, and each dimension must be at least 1; otherwise returns null.
  static ThumbicoSize? tryParse(String text) {
    final parts = text.trim().split(_separator);
    if (parts.length > 2) {
      return null;
    }

    final dimensions = <int>[];
    for (final part in parts) {
      final dimension = _parseDimension(part);
      if (dimension == null) {
        return null;
      }
      dimensions.add(dimension);
    }

    return dimensions.length == 1
        ? ThumbicoSize.square(dimensions[0])
        : ThumbicoSize(dimensions[0], dimensions[1]);
  }

  static int? _parseDimension(String part) {
    final trimmed = part.trim();
    if (!_digits.hasMatch(trimmed)) {
      return null;
    }
    final value = int.tryParse(trimmed);
    return value == null || value < 1 ? null : value;
  }

  bool get isSquare => width == height;

  /// Writes the size in the form [tryParse] reads back, such as `256 x 160`.
  String format() => '$width x $height';

  @override
  bool operator ==(Object other) =>
      other is ThumbicoSize && other.width == width && other.height == height;

  @override
  int get hashCode => Object.hash(width, height);

  @override
  String toString() => format();
}
