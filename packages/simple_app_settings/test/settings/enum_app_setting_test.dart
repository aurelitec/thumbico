// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:simple_app_settings/simple_app_settings.dart';
import 'package:test/test.dart';

import '../temp_directory.dart';

enum Mode { light, dark, system }

void main() {
  late String path;

  setUp(() {
    path = p.join(tempDirectory().path, 'App.settings.json');
  });

  EnumAppSetting<Mode> mode(SettingsStore store, {bool saveOnSet = false}) => EnumAppSetting<Mode>(
    key: 'mode',
    defaultValue: Mode.system,
    values: Mode.values,
    saveOnSet: saveOnSet,
    store: store,
  );

  test('stores the name and reads it back', () {
    mode(SettingsStore.atPath(path), saveOnSet: true).value = Mode.dark;

    expect(jsonDecode(File(path).readAsStringSync()), {'mode': 'dark'});
    expect(mode(SettingsStore.atPath(path)).value, Mode.dark);
  });

  test('gives the default for an unknown name or a non-string', () {
    for (final content in ['{"mode": "sepia"}', '{"mode": 1}', '{"mode": null}']) {
      File(path).writeAsStringSync(content);

      expect(mode(SettingsStore.atPath(path)).value, Mode.system, reason: content);
    }
  });

  test('gives the default when the key is missing', () {
    expect(mode(SettingsStore.atPath(path)).value, Mode.system);
  });
}
