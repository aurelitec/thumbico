// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:simple_app_settings/simple_app_settings.dart';
import 'package:test/test.dart';

import '../temp_directory.dart';

typedef Point = ({int x, int y});

void main() {
  late String path;
  late SettingsStore store;

  setUp(() {
    path = p.join(tempDirectory().path, 'App.settings.json');
    store = SettingsStore.atPath(path);
  });

  ConvertedAppSetting<Set<String>, List<Object?>> tags(SettingsStore store) =>
      ConvertedAppSetting<Set<String>, List<Object?>>(
        key: 'tags',
        defaultValue: const {'default'},
        encode: (set) => set.toList(),
        decode: (list) => list.cast<String>().toSet(),
        store: store,
      );

  ConvertedAppSetting<Point, Map<String, Object?>> origin(SettingsStore store) =>
      ConvertedAppSetting<Point, Map<String, Object?>>(
        key: 'origin',
        defaultValue: (x: 0, y: 0),
        encode: (point) => {'x': point.x, 'y': point.y},
        decode: (map) => (x: map['x'] as int, y: map['y'] as int),
        store: store,
      );

  test('writes the encoded form and reads it back through a fresh store', () {
    tags(store).value = {'a', 'b'};
    origin(store).value = (x: 3, y: 4);

    store.save();

    final written = jsonDecode(File(path).readAsStringSync());
    expect(written, {
      'tags': ['a', 'b'],
      'origin': {'x': 3, 'y': 4},
    });
    final reopened = SettingsStore.atPath(path);
    expect(tags(reopened).value, {'a', 'b'});
    expect(origin(reopened).value, (x: 3, y: 4));
  });

  test('falls back to the default when the stored shape is wrong', () {
    File(path).writeAsStringSync('{"tags": "a,b", "origin": [3, 4]}');
    final loaded = SettingsStore.atPath(path);

    expect(tags(loaded).value, {'default'});
    expect(origin(loaded).value, (x: 0, y: 0));
  });

  test('falls back to the default when decode throws', () {
    File(path).writeAsStringSync('{"tags": [1, 2], "origin": {"x": "3"}}');
    final loaded = SettingsStore.atPath(path);

    expect(tags(loaded).value, {'default'});
    expect(origin(loaded).value, (x: 0, y: 0));
  });

  test('accepts a type the base kind rejects', () {
    expect(() => tags(store), returnsNormally);
  });

  test('saves on set through the encoder', () {
    final setting = ConvertedAppSetting<Set<String>, List<Object?>>(
      key: 'tags',
      defaultValue: const {},
      encode: (set) => set.toList(),
      decode: (list) => list.cast<String>().toSet(),
      saveOnSet: true,
      store: store,
    );

    setting.value = {'a'};

    expect(jsonDecode(File(path).readAsStringSync()), {
      'tags': ['a'],
    });
  });
}
