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
// Toolbar
// ---------------------------------------------------------------------------

const openFileTooltip = 'Open file';
const openFolderTooltip = 'Open folder';
const pathHint = 'File, folder, or drive path';
const sizeHint = 'Size';
const refreshTooltip = 'Ask the shell again';
const optionsTooltip = 'Options';

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
const invalidSize = 'The size must be a number, or two numbers like 256 x 160.';
const itemNotFound = 'Not found';
const noThumbnail = 'No thumbnail';
const shellError = 'The shell could not render this item';
