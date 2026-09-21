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

// The window's placement, written through [save] when the window closes, since a resize would
// otherwise write the file many times a second. Physical pixels in the coordinates Windows keeps
// placements in, and all null until a window has closed once.

/// The left edge of the window while it is not maximized.
final windowLeft = AppSetting<int?>(key: 'windowLeft', defaultValue: null);

/// The top edge of the window while it is not maximized.
final windowTop = AppSetting<int?>(key: 'windowTop', defaultValue: null);

/// The width of the window while it is not maximized, frame included.
final windowWidth = AppSetting<int?>(key: 'windowWidth', defaultValue: null);

/// The height of the window while it is not maximized, frame included.
final windowHeight = AppSetting<int?>(key: 'windowHeight', defaultValue: null);

/// Whether the window was maximized.
final windowMaximized = AppSetting<bool>(key: 'windowMaximized', defaultValue: false);

/// Writes every setting the file holds, including those not saved on set.
void save() => SettingsStore.shared.save();
