// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:meta/meta.dart';

import '../storage/settings_store.dart';
import 'converted_app_setting.dart';

/// True for the types the file holds natively: bool, int, double, String, or a nullable one.
bool isNativeSettingType<T>() =>
    <T>[] is List<bool?> || <T>[] is List<int?> || <T>[] is List<double?> || <T>[] is List<String?>;

/// A setting of a type the file holds natively: bool, int, double, String, or a nullable one.
///
/// Reads its stored value from its store when constructed and falls back to [defaultValue] when
/// the file has no usable one. Assigning [value] changes memory only, unless [saveOnSet] is true.
/// Throws [ArgumentError] for a type the file cannot hold; use [ConvertedAppSetting] for those.
class AppSetting<T>({
  /// The key the value is stored under.
  required final String key,
  required final T defaultValue,

  /// Whether assigning a different value writes the file at once.
  final bool saveOnSet = false,

  /// The store to use instead of [SettingsStore.shared].
  SettingsStore? store,
}) {
  /// The store this setting reads from and saves through.
  final SettingsStore store = store ?? SettingsStore.shared;

  T _value = defaultValue;

  this {
    if (!isConverted && !isNativeSettingType<T>()) {
      throw ArgumentError.value(
        T,
        'T',
        'is not a type the file holds natively; use ConvertedAppSetting',
      );
    }
    this.store.register(key, () => encoded);
    final stored = this.store.lookup(key);
    if (stored.found) {
      _value = decodeStored(stored.value, defaultValue);
    }
  }

  /// The current value.
  T get value => _value;

  /// Replaces the value. An equal value is ignored; a different one is saved when [saveOnSet].
  set value(T value) {
    if (value == _value) {
      return;
    }
    _value = value;
    if (saveOnSet) {
      store.save();
    }
  }

  /// Puts the default back, with the same saving behaviour as assignment.
  void reset() => value = defaultValue;

  /// Whether values are converted on their way to the file. The base kind writes them as they are.
  @protected
  bool get isConverted => false;

  /// The value as it is written to the file.
  @internal
  Object? get encoded => _value;

  /// Turns what the file held into a value, or [fallback] when it cannot.
  ///
  /// The base kind accepts a value of type [T], and an int where a double is expected, since JSON
  /// does not tell them apart once a file has been edited by hand.
  @protected
  T decodeStored(Object? stored, T fallback) {
    if (stored is T) {
      return stored;
    }
    if (stored is int && <T>[] is List<double?>) {
      return stored.toDouble() as T;
    }
    return fallback;
  }
}
