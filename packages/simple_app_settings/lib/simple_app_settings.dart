// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// Keeps an app's settings in one flat JSON file, portable or per user.
library;

export 'src/settings/app_setting.dart' show AppSetting;
export 'src/settings/converted_app_setting.dart' show ConvertedAppSetting;
export 'src/settings/enum_app_setting.dart' show EnumAppSetting;
export 'src/storage/settings_store.dart' show SaveErrorHandler, SettingsStore;
