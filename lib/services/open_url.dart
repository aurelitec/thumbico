// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// Opens web addresses in whatever the user has set as the default browser.
library;

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// Opens [url] in the default browser and returns whether the shell accepted it.
///
/// The shell reports failure as a small number in place of a handle, so a `false` means no
/// browser is registered or it could not be started. The page itself is never checked.
bool openUrl(String url) {
  return using((arena) {
    final result = ShellExecute(
      null,
      arena.pcwstr('open'),
      arena.pcwstr(url),
      null,
      null,
      SW_SHOWNORMAL,
    );
    return result.address > 32;
  });
}
