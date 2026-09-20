// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// The main window's title while an item is shown.
library;

import 'package:path/path.dart' as p;

import 'package:thumbico_core/thumbico_core.dart';

import 'strings.dart' as strings;

/// The window title for the item at [path]: "name - Thumbico", as Windows apps name a document.
///
/// The name is the last part of the path with any trailing slashes dropped; a drive root and a
/// shell string have no such part and are named whole. The path is cleaned the way the core
/// cleans it before reading, so quotes around a pasted path do not reach the title. Call it
/// after a successful read, which is what makes the path name something.
String windowTitle(String path) => '${p.basename(normalizeShellPath(path))} - ${strings.appName}';
