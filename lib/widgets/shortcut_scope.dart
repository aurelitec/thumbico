// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:material_ui/material_ui.dart';

/// Binds the window's keyboard shortcuts around [child] and keeps them working after a click
/// outside the fields.
///
/// A click on the image makes a text field give up focus, and focus then falls to the nearest
/// enclosing scope. Without a scope of its own, that would be the route's scope above the
/// bindings, and the keys would go nowhere. The scope here catches that fall, so the bindings
/// stay in the path of every key event. The scope also takes focus at start, so the keys work
/// before anything is clicked without any field holding the caret.
class const ShortcutScope({
  super.key,

  /// What each shortcut does.
  required final Map<ShortcutActivator, VoidCallback> bindings,

  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: bindings,
      // The scope takes focus at start, so the keys work before anything is clicked
      child: FocusScope(autofocus: true, child: child),
    );
  }
}
