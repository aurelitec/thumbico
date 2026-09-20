// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// The choices the user made, carried between runs.
///
/// Settings marked saveOnSet are written the moment they change. Window bounds change many times
/// a second while the user drags, so the window writes them through [save] when it closes.
library;

import 'package:simple_app_settings/simple_app_settings.dart';
import 'package:thumbico_core/thumbico_core.dart';

/// The text of the size field, as the user typed it.
final sizeText = AppSetting<String>(key: 'sizeText', defaultValue: '256 x 256', saveOnSet: true);

/// Whether the image is drawn at the display's scale rather than one image pixel per screen pixel.
final scaleToDisplay = AppSetting<bool>(
  key: 'scaleToDisplay',
  defaultValue: false,
  saveOnSet: true,
);

final source = EnumAppSetting<ThumbicoSource>(
  key: 'source',
  defaultValue: ThumbicoSource.auto,
  values: ThumbicoSource.values,
  saveOnSet: true,
);

final options = ConvertedAppSetting<Set<ThumbicoOption>, List<Object?>>(
  key: 'options',
  defaultValue: const {},
  encode: (set) => [for (final option in set) option.name],
  decode: (names) => {for (final name in names) ThumbicoOption.values.byName(name as String)},
  saveOnSet: true,
);

/// Null until the window has been closed once; the system then places the window.
final windowLeft = AppSetting<int?>(key: 'windowLeft', defaultValue: null);
final windowTop = AppSetting<int?>(key: 'windowTop', defaultValue: null);
final windowWidth = AppSetting<int>(key: 'windowWidth', defaultValue: 800);
final windowHeight = AppSetting<int>(key: 'windowHeight', defaultValue: 600);
final windowMaximized = AppSetting<bool>(key: 'windowMaximized', defaultValue: false);

/// Writes what was not saved on set.
void save() => SettingsStore.shared.save();
