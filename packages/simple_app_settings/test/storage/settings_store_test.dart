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

  setUp(() {
    path = p.join(tempDirectory().path, 'App.settings.json');
  });

  group('opening', () {
    test('finds nothing when there is no file', () {
      final store = SettingsStore.atPath(path);

      expect(store.path, path);
      expect(store.isPortable, isFalse);
      expect(store.lookup('any'), (found: false, value: null));
    });

    test('reads what the file held', () {
      File(path).writeAsStringSync('{"count": 3, "name": "x", "gone": null}');

      final store = SettingsStore.atPath(path);

      expect(store.lookup('count'), (found: true, value: 3));
      expect(store.lookup('name'), (found: true, value: 'x'));
      expect(store.lookup('gone'), (found: true, value: null));
      expect(store.lookup('other'), (found: false, value: null));
    });

    test('treats an empty, corrupt, or non-object file as empty', () {
      for (final content in ['', 'not json', '[1, 2]', '"text"', '42']) {
        File(path).writeAsStringSync(content);

        expect(SettingsStore.atPath(path).lookup('count').found, isFalse, reason: content);
      }
    });

    test('treats an unreadable path as empty', () {
      Directory(path).createSync();

      expect(SettingsStore.atPath(path).lookup('count').found, isFalse);
    });
  });

  group('save', () {
    test('writes the registered values and keeps the keys nobody claimed', () {
      File(path).writeAsStringSync('{"legacy": true, "count": 1}');
      final store = SettingsStore.atPath(path)..register('count', () => 2);

      store.save();

      final written = jsonDecode(File(path).readAsStringSync());
      expect(written, {'legacy': true, 'count': 2});
    });

    test('is seen by a fresh store on the same path', () {
      SettingsStore.atPath(path)
        ..register('count', () => 2)
        ..save();

      expect(SettingsStore.atPath(path).lookup('count'), (found: true, value: 2));
    });

    test('creates the directory and leaves no temporary file', () {
      final nested = p.join(p.dirname(path), 'a', 'b', 'App.settings.json');
      final store = SettingsStore.atPath(nested)..register('count', () => 2);

      store.save();

      expect(File(nested).existsSync(), isTrue);
      expect(File('$nested.tmp').existsSync(), isFalse);
    });

    test('writes indented JSON', () {
      SettingsStore.atPath(path)
        ..register('count', () => 2)
        ..save();

      expect(File(path).readAsStringSync(), '{\n  "count": 2\n}');
    });

    test('reports a failure to the handler and does not throw', () {
      // A file where the directory should be makes every write below it fail.
      File(path).writeAsStringSync('');
      final blocked = p.join(path, 'App.settings.json');
      Object? reported;
      final store = SettingsStore.atPath(blocked, onSaveError: (error, _) => reported = error);

      expect(store.save, returnsNormally);
      expect(reported, isA<FileSystemException>());
    });

    test('drops a failure when there is no handler', () {
      File(path).writeAsStringSync('');
      final blocked = p.join(path, 'App.settings.json');

      expect(SettingsStore.atPath(blocked).save, returnsNormally);
    });

    test('reports an encoder that throws', () {
      Object? reported;
      final store = SettingsStore.atPath(path, onSaveError: (error, _) => reported = error)
        ..register('count', () => throw StateError('cannot encode'));

      store.save();

      expect(reported, isA<StateError>());
      expect(File(path).existsSync(), isFalse);
    });
  });

  test('register rejects a key that is already registered', () {
    final store = SettingsStore.atPath(path)..register('count', () => 1);

    expect(() => store.register('count', () => 2), throwsStateError);
  });
}
