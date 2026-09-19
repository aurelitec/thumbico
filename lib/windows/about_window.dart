// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

// The windowing API is still internal, so opening a window needs implementation imports.
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: implementation_imports

import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/_window.dart';

import 'package:material_ui/material_ui.dart';

import '../common/strings.dart' as strings;
import '../common/theme.dart';

/// The About window: a real dialog window, modal to the main window and centred over it.
class const AboutWindow({
  super.key,

  /// Closes the window; the Close button and Escape both call it.
  required final VoidCallback onClose,
}) extends StatelessWidget {
  /// The size of the window's content.
  ///
  /// Stated rather than taken from the content, because the engine centres a dialog over its
  /// parent only when it is given a size; one sized to its content opens wherever Windows'
  /// cascade puts it.
  static const size = Size(360, 240);

  /// Opens the window over [parent], which it blocks until it is closed.
  ///
  /// Creating a native window pumps the Windows message loop, so it is done from a message-loop
  /// task of its own, never inside a frame. That makes it safe from any handler, including a
  /// menu item's, which the framework runs in a post-frame callback; made right there, the
  /// window's first frame began inside the menu's and tripped the scheduler's idle check.
  static void open(BuildContext context, BaseWindowController parent) {
    final registry = WindowRegistry.of(context);
    Future(() => _open(registry, parent));
  }

  /// Creates the native window and hands its content to [registry] to be rendered.
  static void _open(WindowRegistry registry, BaseWindowController parent) {
    late final WindowEntry entry;
    late final DialogWindowController controller;

    // Takes the window out of the registry, once: a destruction reports back here too
    var registered = true;
    void leaveRegistry() {
      if (registered) {
        registered = false;
        registry.unregister(entry);
      }
    }

    // Out of the registry first and destroyed second, the order the registry asks for
    void close() {
      leaveRegistry();
      controller.destroy();
    }

    // Creating the controller is what creates the native window. Made through the owner
    // because the controller's own sized constructor hardcodes a resizable window.
    controller = WidgetsBinding.instance.windowingOwner.createDialogWindowController(
      size: size,
      resizable: false,
      title: strings.aboutWindowTitle,
      parent: parent,
      delegate: _AboutWindowDelegate(onClose: close, onDestroyed: leaveRegistry),
    );

    // A view of its own at the root, so it brings its own theme and text direction. Not a whole
    // MaterialApp, since the content needs no navigator, overlay, or localizations.
    entry = WindowEntry(
      controller: controller,
      builder: (context) => Theme(
        data: appTheme(),
        child: Directionality(
          textDirection: .ltr,
          child: AboutWindow(onClose: close),
        ),
      ),
    );

    // Registering is what makes the window manager render the window
    registry.register(entry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Escape closes the window, as in every Windows dialog; the scope takes focus so that the
    // key is heard before anything is clicked
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): onClose},
      child: FocusScope(
        autofocus: true,
        child: Material(
          child: Center(
            child: Column(
              mainAxisSize: .min,
              spacing: 16,
              children: [
                // The name and the version
                Text(strings.appName, style: theme.textTheme.headlineSmall),
                const Text('${strings.versionLabel} ${strings.appVersion}'),

                // The way out for the mouse
                FilledButton(onPressed: onClose, child: const Text(strings.closeLabel)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sends the title bar's close button down the same path as the Close button, and keeps the
/// registry right when the window is destroyed without being asked, as when its parent closes.
class _AboutWindowDelegate({
  required final VoidCallback onClose,
  required final VoidCallback onDestroyed,
}) with DialogWindowControllerDelegate {
  @override
  void onWindowCloseRequested(DialogWindowController controller) => onClose();

  @override
  void onWindowDestroyed() {
    super.onWindowDestroyed();
    onDestroyed();
  }
}
