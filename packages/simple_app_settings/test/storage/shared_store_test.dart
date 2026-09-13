// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:path/path.dart' as p;
import 'package:simple_app_settings/simple_app_settings.dart';
import 'package:test/test.dart';

import '../temp_directory.dart';

void main() {
  test('shared throws until it is set', () {
    expect(() => SettingsStore.shared, throwsStateError);
  });

  test('shared returns the store that was set', () {
    final store = SettingsStore.atPath(p.join(tempDirectory().path, 'App.settings.json'));

    SettingsStore.shared = store;

    expect(SettingsStore.shared, same(store));
  });
}
