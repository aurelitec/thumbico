// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'app_setting.dart';

/// A setting of any type, stored as [S] through two converters.
///
/// [S] is one of the shapes JSON decodes to: bool, int, double, String, `List<Object?>`,
/// `Map<String, Object?>`, or a nullable one of these. [decode] may throw for a value it does not
/// accept; the setting then falls back to its default.
class ConvertedAppSetting<T, S>({
  required super.key,
  required super.defaultValue,

  /// Turns a value into what the file stores.
  required final S Function(T value) encode,

  /// Turns what the file stores back into a value.
  required final T Function(S stored) decode,
  super.saveOnSet,
  super.store,
}) extends AppSetting<T> {
  @override
  bool get isConverted => true;

  @override
  Object? get encoded => encode(value);

  @override
  T decodeStored(Object? stored, T fallback) {
    if (stored is! S) {
      return fallback;
    }
    try {
      return decode(stored);
    } on Object {
      return fallback;
    }
  }
}
