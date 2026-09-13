// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'settings_location.dart';

/// Receives a failure to write the settings file. The app decides whether to log it.
typedef SaveErrorHandler = void Function(Object error, StackTrace stackTrace);

/// The settings file: where it is, what it held when it was opened, and how to write it.
///
/// The file is read once, at construction. Settings register themselves with the store and are
/// written by [save], together with any key the file held that no setting claimed.
final class SettingsStore._(
  /// The file this store reads and writes.
  final String path, {

  /// True when the file was found beside the executable.
  required final bool isPortable,
  final SaveErrorHandler? onSaveError,
}) {
  /// Follows the location rule for the app named by [company] and [product] and reads the file.
  ///
  /// Throws [UnsupportedError] when there is no portable file and `LOCALAPPDATA` is not set.
  factory forApp({
    required String company,
    required String product,
    SaveErrorHandler? onSaveError,
  }) {
    final location = resolveSettingsLocation(
      executableDirectory: p.dirname(Platform.resolvedExecutable),
      localAppData: Platform.environment['LOCALAPPDATA'],
      company: company,
      product: product,
      exists: (path) => File(path).existsSync(),
    );
    return SettingsStore._(
      location.path,
      isPortable: location.isPortable,
      onSaveError: onSaveError,
    );
  }

  /// Uses the file at [path] and reads it. For tests and special cases.
  factory atPath(String path, {SaveErrorHandler? onSaveError}) =>
      SettingsStore._(path, isPortable: false, onSaveError: onSaveError);

  static SettingsStore? _shared;

  /// The store every setting uses unless given another. Set it first thing in `main`.
  ///
  /// Reading it before it is set throws a [StateError].
  static SettingsStore get shared =>
      _shared ??
      (throw StateError(
        'SettingsStore.shared has not been set. Set it before any setting is used.',
      ));

  static set shared(SettingsStore store) => _shared = store;

  // What the file held when it was opened, brought up to date by save. Never exposed.
  final Map<String, Object?> _raw = _read(path);

  final _encoders = <String, Object? Function()>{};

  static Map<String, Object?> _read(String path) {
    try {
      final decoded = jsonDecode(File(path).readAsStringSync());
      return decoded is Map<String, Object?> ? decoded : {};
    } on FileSystemException {
      return {};
    } on FormatException {
      return {};
    }
  }

  /// Registers a setting's key and how to encode its value for the file.
  ///
  /// Throws [StateError] when the key is already registered.
  @internal
  void register(String key, Object? Function() encode) {
    if (_encoders.containsKey(key)) {
      throw StateError('A setting with the key "$key" is already registered with this store');
    }
    _encoders[key] = encode;
  }

  /// The value the file held under [key], and whether it held one at all.
  @internal
  ({bool found, Object? value}) lookup(String key) =>
      (found: _raw.containsKey(key), value: _raw[key]);

  /// Writes every registered setting, keeping any other key the file held.
  ///
  /// Synchronous and atomic: the JSON goes to a temporary file that is renamed over [path]. A
  /// failure is reported to the error handler and never thrown.
  void save() {
    try {
      for (final entry in _encoders.entries) {
        _raw[entry.key] = entry.value();
      }
      final json = const JsonEncoder.withIndent('  ').convert(_raw);
      Directory(p.dirname(path)).createSync(recursive: true);
      final temporary = File('$path.tmp')..writeAsStringSync(json);
      temporary.renameSync(path);
    } catch (error, stackTrace) {
      onSaveError?.call(error, stackTrace);
    }
  }
}
