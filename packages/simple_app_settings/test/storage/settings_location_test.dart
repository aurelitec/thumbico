// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:path/path.dart' as p;
import 'package:simple_app_settings/src/storage/settings_location.dart';
import 'package:test/test.dart';

void main() {
  final executableDirectory = p.join('C:', 'Apps', 'Notes');
  final localAppData = p.join('C:', 'Users', 'me', 'AppData', 'Local');
  final portableFile = p.join(executableDirectory, 'Notes.settings.json');

  test('uses the file beside the executable when it exists', () {
    final location = resolveSettingsLocation(
      executableDirectory: executableDirectory,
      localAppData: localAppData,
      company: 'Example',
      product: 'Notes',
      exists: (path) => path == portableFile,
    );

    expect(location.path, portableFile);
    expect(location.isPortable, isTrue);
  });

  test('falls back to Local AppData under the company and product', () {
    final location = resolveSettingsLocation(
      executableDirectory: executableDirectory,
      localAppData: localAppData,
      company: 'Example',
      product: 'Notes',
      exists: (_) => false,
    );

    expect(location.path, p.join(localAppData, 'Example', 'Notes', 'Notes.settings.json'));
    expect(location.isPortable, isFalse);
  });

  test('throws when there is no portable file and no Local AppData', () {
    for (final missing in [null, '']) {
      expect(
        () => resolveSettingsLocation(
          executableDirectory: executableDirectory,
          localAppData: missing,
          company: 'Example',
          product: 'Notes',
          exists: (_) => false,
        ),
        throwsUnsupportedError,
        reason: 'localAppData $missing',
      );
    }
  });

  test('prefers the portable file even when Local AppData is missing', () {
    final location = resolveSettingsLocation(
      executableDirectory: executableDirectory,
      localAppData: null,
      company: 'Example',
      product: 'Notes',
      exists: (path) => path == portableFile,
    );

    expect(location.isPortable, isTrue);
  });
}
