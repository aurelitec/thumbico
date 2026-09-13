// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:path/path.dart' as p;

/// Where the settings file is, and whether it was found beside the executable.
typedef SettingsLocation = ({String path, bool isPortable});

/// The location rule, as a pure function of its inputs.
///
/// A file named `<product>.settings.json` in [executableDirectory] marks a portable install and
/// is the settings file. Otherwise the file is `<localAppData>/<company>/<product>/` plus that
/// name. [exists] answers whether a path is an existing file. Throws [UnsupportedError] when the
/// portable file is absent and [localAppData] is null or empty.
SettingsLocation resolveSettingsLocation({
  required String executableDirectory,
  required String? localAppData,
  required String company,
  required String product,
  required bool Function(String path) exists,
}) {
  final fileName = '$product.settings.json';
  final portable = p.join(executableDirectory, fileName);
  if (exists(portable)) {
    return (path: portable, isPortable: true);
  }
  if (localAppData == null || localAppData.isEmpty) {
    throw UnsupportedError('LOCALAPPDATA is not set, so there is no place for the settings file');
  }
  return (path: p.join(localAppData, company, product, fileName), isPortable: false);
}
