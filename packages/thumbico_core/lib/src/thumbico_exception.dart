// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// What kind of shell failure a [ThumbicoException] reports.
enum ThumbicoFailure {
  /// The file or path does not exist.
  itemNotFound,

  /// The item has no thumbnail handler. Only reachable when asking for a thumbnail only.
  noThumbnail,

  /// Any other shell error, reported with its code.
  shellError,
}

/// A failed shell call, with the HRESULT and the path it was made for.
final class ThumbicoException({
  /// The HRESULT as the shell returned it; use [hresultHex] to display it.
  required final int hresult,

  /// The normalized path the call was made for.
  required final String path,

  /// The name of the call that failed.
  required final String operation,
}) implements Exception {
  /// The category [hresult] falls into, which is what a consumer switches over.
  final ThumbicoFailure failure = classify(hresult);

  /// The HRESULT as eight hexadecimal digits, the form Windows documents it in.
  String get hresultHex =>
      '0x${hresult.toUnsigned(32).toRadixString(16).toUpperCase().padLeft(8, '0')}';

  /// The failure in one line, for a log rather than for the user.
  String get message => '$operation failed for "$path" with $hresultHex';

  /// Sorts an HRESULT into the categories a consumer can act on.
  static ThumbicoFailure classify(int hresult) => switch (hresult.toUnsigned(32)) {
    0x80070002 || 0x80070003 => ThumbicoFailure.itemNotFound,
    0x8004B200 => ThumbicoFailure.noThumbnail,
    _ => ThumbicoFailure.shellError,
  };

  @override
  String toString() => 'ThumbicoException: $message';
}
