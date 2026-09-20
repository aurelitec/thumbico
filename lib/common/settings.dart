// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// The choices the user made, carried between runs.
///
/// A setting declared with saveOnSet is written the moment it changes, so nothing is lost if the
/// app is closed or crashes. Any other setting reaches the file only through [save].
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

/// Which kind of image the shell is asked for.
final source = EnumAppSetting<ThumbicoSource>(
  key: 'source',
  defaultValue: ThumbicoSource.auto,
  values: ThumbicoSource.values,
  saveOnSet: true,
);

/// The shell options that are on, stored by name so that reordering the enum changes nothing.
final options = ConvertedAppSetting<Set<ThumbicoOption>, List<Object?>>(
  key: 'options',
  defaultValue: const {},
  encode: (set) => [for (final option in set) option.name],
  decode: (names) => {for (final name in names) ThumbicoOption.values.byName(name as String)},
  saveOnSet: true,
);

// The window's placement. Nothing reads or writes these yet: the window opens at a fixed size and
// Windows places it.

/// The window's left edge on screen.
final windowLeft = AppSetting<int?>(key: 'windowLeft', defaultValue: null);

/// The window's top edge on screen.
final windowTop = AppSetting<int?>(key: 'windowTop', defaultValue: null);

/// The width of the window's content.
final windowWidth = AppSetting<int>(key: 'windowWidth', defaultValue: 800);

/// The height of the window's content.
final windowHeight = AppSetting<int>(key: 'windowHeight', defaultValue: 600);

/// Whether the window was maximized.
final windowMaximized = AppSetting<bool>(key: 'windowMaximized', defaultValue: false);

/// Writes every setting the file holds, including those not saved on set.
void save() => SettingsStore.shared.save();
