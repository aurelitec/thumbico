# simple_app_settings

Keeps an app's settings in one flat JSON file. A file beside the executable marks a portable copy and is used as is; otherwise the file lives under the user's Local AppData. Pure Dart, no Flutter dependency.

## Usage

Set the shared store first thing in `main`, then declare each setting once, as a top-level final in one library:

```dart
import 'package:simple_app_settings/simple_app_settings.dart';

void main() {
  SettingsStore.shared = SettingsStore.forApp(company: 'Example', product: 'Notes');
  // ...
}

// settings.dart, imported elsewhere as `settings`
final fontSize = AppSetting<int>(key: 'fontSize', defaultValue: 12, saveOnSet: true);

enum Theme { light, dark }

final theme = EnumAppSetting<Theme>(
  key: 'theme',
  defaultValue: Theme.light,
  values: Theme.values,
  saveOnSet: true,
);

final windowWidth = AppSetting<int>(key: 'windowWidth', defaultValue: 800);

/// Writes what was not saved on set. Called when the window closes.
void save() => SettingsStore.shared.save();
```

Read and assign `value`. A setting with `saveOnSet: true` writes the file after each change; the others are written when the app calls `save()`.

`AppSetting<T>` holds what JSON holds natively: `bool`, `int`, `double`, `String`, or a nullable one of these. Anything else goes through `ConvertedAppSetting<T, S>` with an `encode` and a `decode` function, where `S` is a JSON shape (`List<Object?>`, `Map<String, Object?>`, or a scalar). `EnumAppSetting` is the converted setting for enums, stored by name.

## Behaviour

- The file is read once, when the store is constructed. A missing, unreadable, or corrupt file gives defaults, and so does a value of the wrong shape. Loading never fails.
- `save()` writes every registered setting and keeps any other key the file held. The write goes to a temporary file that is renamed over the target, so a crash mid-write leaves the old file or the new one, never a torn one.
- A save failure is passed to the store's `onSaveError` handler. Without a handler it is dropped.
- The location is `<Product>.settings.json` beside the executable if that file exists, otherwise `%LOCALAPPDATA%\<Company>\<Product>\<Product>.settings.json`. Ship an empty file or `{}` beside a portable build.

## Tests

Construct a store with `SettingsStore.atPath` under a temporary directory and pass it as `store:` to the settings under test, or set it as `SettingsStore.shared`.
