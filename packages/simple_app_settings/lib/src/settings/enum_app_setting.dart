// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'converted_app_setting.dart';

/// An enum setting, stored by name so that reordering the enum does not change a saved choice.
///
/// A stored name that is not in [values] gives the default.
class EnumAppSetting<T extends Enum>({
  required super.key,
  required super.defaultValue,

  /// The enum's values, normally its `values` list.
  required List<T> values,
  super.saveOnSet,
  super.store,
}) extends ConvertedAppSetting<T, String> {
  this : super(encode: (value) => value.name, decode: (name) => values.byName(name));
}
