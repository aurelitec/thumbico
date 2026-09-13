// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:simple_app_settings/simple_app_settings.dart';
import 'package:test/test.dart';

import '../temp_directory.dart';

void main() {
  late String path;
  late SettingsStore store;

  setUp(() {
    path = p.join(tempDirectory().path, 'App.settings.json');
    store = SettingsStore.atPath(path);
  });

  SettingsStore storeWith(String json) {
    File(path).writeAsStringSync(json);
    return SettingsStore.atPath(path);
  }

  Object? written(String key) => (jsonDecode(File(path).readAsStringSync()) as Map)[key];

  group('initial value', () {
    test('is the default when the file has no value', () {
      final setting = AppSetting<int>(key: 'count', defaultValue: 7, store: store);

      expect(setting.value, 7);
      expect(setting.defaultValue, 7);
      expect(setting.key, 'count');
      expect(setting.store, same(store));
    });

    test('is read back for each native type', () {
      final loaded = storeWith('{"b": true, "i": 3, "d": 1.5, "s": "x"}');

      expect(AppSetting<bool>(key: 'b', defaultValue: false, store: loaded).value, isTrue);
      expect(AppSetting<int>(key: 'i', defaultValue: 0, store: loaded).value, 3);
      expect(AppSetting<double>(key: 'd', defaultValue: 0, store: loaded).value, 1.5);
      expect(AppSetting<String>(key: 's', defaultValue: '', store: loaded).value, 'x');
    });

    test('is a stored null for a nullable setting, and the default when the key is missing', () {
      final loaded = storeWith('{"present": null}');

      expect(AppSetting<int?>(key: 'present', defaultValue: 5, store: loaded).value, isNull);
      expect(AppSetting<int?>(key: 'missing', defaultValue: 5, store: loaded).value, 5);
    });

    test('accepts an int where a double is expected', () {
      final loaded = storeWith('{"d": 2}');

      expect(AppSetting<double>(key: 'd', defaultValue: 0, store: loaded).value, 2.0);
    });

    test('is the default for a value of the wrong type', () {
      final loaded = storeWith('{"i": "three", "b": 1, "s": null}');

      expect(AppSetting<int>(key: 'i', defaultValue: 0, store: loaded).value, 0);
      expect(AppSetting<bool>(key: 'b', defaultValue: true, store: loaded).value, isTrue);
      expect(AppSetting<String>(key: 's', defaultValue: 'd', store: loaded).value, 'd');
    });
  });

  group('assignment', () {
    test('changes memory only by default', () {
      final setting = AppSetting<int>(key: 'count', defaultValue: 0, store: store);

      setting.value = 9;

      expect(setting.value, 9);
      expect(File(path).existsSync(), isFalse);
    });

    test('is written by the store on save', () {
      AppSetting<int>(key: 'count', defaultValue: 0, store: store).value = 9;

      store.save();

      expect(written('count'), 9);
    });

    test('with saveOnSet writes a different value and ignores an equal one', () {
      final setting = AppSetting<int>(key: 'count', defaultValue: 0, saveOnSet: true, store: store);

      setting.value = 0;
      expect(File(path).existsSync(), isFalse, reason: 'equal to the current value');

      setting.value = 9;
      expect(written('count'), 9);
    });

    test('reset puts the default back with the same saving behaviour', () {
      final setting = AppSetting<int>(key: 'count', defaultValue: 4, saveOnSet: true, store: store)
        ..value = 9;

      setting.reset();

      expect(setting.value, 4);
      expect(written('count'), 4);
    });
  });

  group('errors', () {
    test('rejects a type the file cannot hold natively', () {
      expect(
        () => AppSetting<List<int>>(key: 'list', defaultValue: const [], store: store),
        throwsArgumentError,
      );
      expect(
        () => AppSetting<Object>(key: 'any', defaultValue: 1, store: store),
        throwsArgumentError,
      );
    });

    test('rejects a second setting with the same key on one store', () {
      AppSetting<int>(key: 'count', defaultValue: 0, store: store);

      expect(() => AppSetting<int>(key: 'count', defaultValue: 0, store: store), throwsStateError);
    });
  });

  test('uses the shared store when none is given', () {
    SettingsStore.shared = store;

    final setting = AppSetting<int>(key: 'count', defaultValue: 0);

    expect(setting.store, same(store));
  });
}
