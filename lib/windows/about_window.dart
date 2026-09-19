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
import '../common/urls.dart' as urls;

/// The About window: a real dialog window, modal to the main window and centred over it.
class const AboutWindow({
  super.key,

  /// Closes the window; the Close button and Escape both call it.
  required final VoidCallback onClose,

  /// Opens one of the window's links in the browser.
  required final void Function(String url) onOpenUrl,
}) extends StatelessWidget {
  /// The app icon, stored at more than twice its drawn size so it stays sharp on a scaled
  /// display.
  static const _iconAsset = 'assets/app_icon.png';

  /// The size the icon is drawn at.
  static const _iconSize = 96.0;

  /// The room between the window's sections.
  static const _sectionGap = SizedBox(height: 16);

  /// The size of the window's content.
  ///
  /// Stated rather than taken from the content, because the engine centres a dialog over its
  /// parent only when it is given a size; one sized to its content opens wherever Windows'
  /// cascade puts it.
  static const size = Size(360, 400);

  /// Opens the window over [parent], which it blocks until it is closed.
  ///
  /// Creating a native window pumps the Windows message loop, so it is done from a message-loop
  /// task of its own, never inside a frame. That makes it safe from any handler, including a
  /// menu item's, which the framework runs in a post-frame callback; made right there, the
  /// window's first frame began inside the menu's and tripped the scheduler's idle check.
  static void open(
    BuildContext context,
    BaseWindowController parent, {
    required void Function(String url) onOpenUrl,
  }) {
    final registry = WindowRegistry.of(context);
    Future(() => _open(registry, parent, onOpenUrl));
  }

  /// Creates the native window and hands its content to [registry] to be rendered.
  static void _open(
    WindowRegistry registry,
    BaseWindowController parent,
    void Function(String url) onOpenUrl,
  ) {
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

    // A view of its own at the root, so it carries its own app, as the main window does. The
    // app is what makes it a keyboard citizen: Tab and the arrows between controls, and Enter
    // and Space on the focused one, are its default shortcuts and actions. Hosted under a bare
    // theme at first, the window heard only the Escape it binds itself.
    entry = WindowEntry(
      controller: controller,
      builder: (context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: strings.aboutWindowTitle,
        theme: appTheme(),
        darkTheme: appTheme(.dark),
        home: AboutWindow(onClose: close, onOpenUrl: onOpenUrl),
      ),
    );

    // Registering is what makes the window manager render the window
    registry.register(entry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Fainter than the name and the version, which are what the window is opened for
    final muted = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    // Escape closes the window, as in every Windows dialog
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): onClose},
      child: Material(
        child: Center(
          child: Column(
            mainAxisSize: .min,
            children: [
              // The app icon
              Image.asset(
                _iconAsset,
                width: _iconSize,
                height: _iconSize,
                filterQuality: .medium,
                excludeFromSemantics: true,
              ),

              // The name and the version
              _sectionGap,
              Text(strings.appName, style: theme.textTheme.headlineSmall),
              const Text('${strings.versionLabel} ${strings.appVersion}'),

              // Whose it is, and where it lives on the web
              _sectionGap,
              Text(strings.copyright, style: muted),
              _Link(strings.homeLinkLabel, onPressed: () => onOpenUrl(urls.home)),

              // The licence, and where the source is
              _sectionGap,
              Text(strings.license, style: muted),
              _Link(strings.sourceLinkLabel, onPressed: () => onOpenUrl(urls.source)),

              // The way out, holding the focus from the start as a Windows default button
              // does, so that Enter closes the window and Escape is heard at once
              _sectionGap,
              FilledButton(
                autofocus: true,
                onPressed: onClose,
                child: const Text(strings.closeLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A text button drawn as a link: underlined, in the accent, with the hand under the pointer.
///
/// A link shows no box under the pointer, as a button does; the tint is kept for keyboard focus
/// alone, which has no other sign.
class const _Link(final String label, {required final VoidCallback onPressed})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    return TextButton(
      style:
          TextButton.styleFrom(
            foregroundColor: color,
            enabledMouseCursor: SystemMouseCursors.click,
            // The underline's colour is named, since Material's label style carries a black or
            // white one of its own, which the button's text colour does not replace
            textStyle: theme.textTheme.labelLarge?.copyWith(
              decoration: .underline,
              decorationColor: color,
            ),
          ).copyWith(
            overlayColor: WidgetStateProperty.fromMap({
              WidgetState.focused: color.withValues(alpha: 0.1),
              WidgetState.any: Colors.transparent,
            }),
          ),
      onPressed: onPressed,
      child: Text(label),
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
