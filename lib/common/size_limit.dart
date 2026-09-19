// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// The largest size this app asks the shell for.
///
/// The shell and the core have no limit; this one protects the user's machine. An image of this
/// size is 256 MB and a read holds about three of them, and it is the largest texture that
/// Direct3D guarantees on older graphics hardware.
library;

import 'dart:math' show max;

import 'package:thumbico_core/thumbico_core.dart';

/// The most pixels either side of a requested size may have.
const maximumSide = 8192;

/// The largest size as a whole, for showing to the user.
const maximumSize = ThumbicoSize.square(maximumSide);

/// Whether either side of [size] is past the maximum.
bool exceedsMaximum(ThumbicoSize size) => max(size.width, size.height) > maximumSide;

/// [size] itself if it is within the maximum, or else scaled down to it with its shape kept.
ThumbicoSize fittedToMaximum(ThumbicoSize size) =>
    exceedsMaximum(size) ? size.scaled(maximumSide / max(size.width, size.height)) : size;
