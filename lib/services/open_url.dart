// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// Opens web addresses in whatever the user has set as the default browser.
library;

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// Opens [url] in the default browser and completes with whether the shell accepted it.
///
/// The shell pumps the message loop while it works, so the call runs from a message-loop task
/// of its own, never inside a frame. That makes it safe from any handler, including a menu
/// item's, which the framework runs in a post-frame callback. A `false` means no browser is
/// registered or it could not be started; the page itself is never checked.
Future<bool> openUrl(String url) {
  return Future(() {
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
  });
}
