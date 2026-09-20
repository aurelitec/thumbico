// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:win32/win32.dart';

import '../thumbico_exception.dart';

/// Runs [body] with a COM apartment on the current thread.
///
/// A thread that already has one, such as the Flutter main isolate on the runner thread, is left
/// alone. Otherwise a single-threaded apartment is entered for the duration of [body] and left
/// afterwards. [path] is only used to report a failure to initialize COM.
T withComApartment<T>(String path, T Function() body) {
  if (isComInitialized) {
    return body();
  }

  final hr = CoInitializeEx(COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
  if (hr.isError) {
    throw ThumbicoException(hresult: hr, path: path, operation: 'CoInitializeEx');
  }

  try {
    return body();
  } finally {
    CoUninitialize();
  }
}
