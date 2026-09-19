// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// Contains user-facing strings used throughout the application.
library;

import 'package:thumbico_core/thumbico_core.dart';

// ---------------------------------------------------------------------------
// App
// ---------------------------------------------------------------------------

const appName = 'Thumbico';
const companyName = 'Aurelitec';

// ---------------------------------------------------------------------------
// Main Window
// ---------------------------------------------------------------------------

const mainWindowTitle = 'Thumbico';

// ---------------------------------------------------------------------------
// About Window
// ---------------------------------------------------------------------------

const aboutWindowTitle = 'About Thumbico';

/// Kept equal to the version in pubspec.yaml by a test.
const appVersion = '1.0.0';
const versionLabel = 'Version';
const closeLabel = 'Close';

// ---------------------------------------------------------------------------
// Toolbar
// ---------------------------------------------------------------------------

const openFileTooltip = 'Open file (Ctrl+O)';
const openFolderTooltip = 'Open folder (Ctrl+Shift+O)';
const pathHint = 'File, folder, or drive path';
const sizeHint = 'Size';
const refreshTooltip = 'Ask the shell again (F5)';
const optionsTooltip = 'Options';

// ---------------------------------------------------------------------------
// Size flyout
// ---------------------------------------------------------------------------

const sizesTooltip = 'Sizes';
// The number is SizeField.stepFactor written out; a test keeps the two in step.
const biggerTooltip = 'Bigger x 1.25 (Ctrl++)';
const smallerTooltip = 'Smaller / 1.25 (Ctrl+-)';
const displayScaleTooltip = 'Display scale instead of real pixels';

// ---------------------------------------------------------------------------
// Options flyout
// ---------------------------------------------------------------------------

const Map<ThumbicoSource, String> sourceLabels = {
  .auto: 'Best',
  .thumbnailOnly: 'Thumbnail',
  .iconOnly: 'Icon',
};

const Map<ThumbicoOption, String> optionLabels = {
  .allowLargerSize: 'Allow larger than asked',
  .inMemoryOnly: 'Only if already in memory',
  .inCacheOnly: 'Only if already cached',
  .cropToSquare: 'Crop to square',
  .wideAspect: 'Wide aspect (0.7)',
  .iconBackground: 'App colour behind icons',
  .scaleUp: 'Scale small images up',
};

// ---------------------------------------------------------------------------
// Overflow menu
// ---------------------------------------------------------------------------

const moreTooltip = 'More';
const saveAsLabel = 'Save As...';
const copyLabel = 'Copy';
const showcaseLabel = 'Showcase mode';

// The keys as the menu shows them; a test keeps each equal to the framework's own label for
// the shortcut in common/shortcuts.dart.
const saveAsShortcut = 'Ctrl+S';
const copyShortcut = 'Ctrl+Shift+C';
const showcaseShortcut = 'F11';
const helpShortcut = 'F1';

// ---------------------------------------------------------------------------
// Showcase mode
// ---------------------------------------------------------------------------

const exitShowcaseLabel = 'Exit Showcase';
const exitShowcaseTooltip = 'Exit Showcase mode (F11, Esc)';
const helpLabel = 'Help';
const aboutLabel = 'About Thumbico';
const exitLabel = 'Exit';

// ---------------------------------------------------------------------------
// Save As dialog
// ---------------------------------------------------------------------------

/// The file types offered, in the order shown; the first is the default.
const Map<String, String> saveFilters = {
  'PNG image (*.png)': '*.png',
  'Icon (*.ico)': '*.ico',
  'JPEG image (*.jpg)': '*.jpg;*.jpeg',
  'Bitmap (*.bmp)': '*.bmp',
  'GIF image (*.gif)': '*.gif',
};

// ---------------------------------------------------------------------------
// Status bar
// ---------------------------------------------------------------------------

const askedFor = 'Asked for';
const returned = 'Returned';
const kindIcon = 'Icon';
const kindThumbnail = 'Thumbnail';

// ---------------------------------------------------------------------------
// Messages
// ---------------------------------------------------------------------------

const enterPath = 'Enter a path and press Enter.';
const invalidSize =
    'The size must be a whole number from 1 up, or two such numbers like 256 x 160.';

/// Followed by the largest size, which the window adds.
const largestSizeIs = 'The largest size you can ask for is';
const itemNotFound = 'Not found';
const noThumbnail = 'No thumbnail';
const shellError = 'The shell could not render this item';
const couldNotOpenBrowser = 'Could not open the browser.';
const savedTo = 'Saved to';
const couldNotSave = 'Could not save the image:';
const unknownSaveFormat = 'End the file name with .png, .ico, .jpg, .bmp, or .gif.';
const tooLargeForIco =
    'An icon file holds at most 256 x 256 pixels. Save as PNG, or ask for a smaller size.';
const copied = 'Copied to the clipboard.';
const couldNotCopy = 'Could not copy to the clipboard.';
