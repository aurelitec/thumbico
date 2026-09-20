// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../common/strings.dart' as strings;

/// What the window does for each item of the overflow menu.
///
/// One bundle travels from the window through the toolbar to the menu, so a new item adds a
/// field here rather than a parameter on every widget in between.
class const OverflowCallbacks({
  /// Saves the image; null while there is nothing to save, which disables the item.
  final VoidCallback? onSaveAs,

  /// Copies the image; null while there is nothing to copy, which disables the item.
  final VoidCallback? onCopy,

  /// Enters Showcase mode.
  required final VoidCallback onShowcase,

  /// Opens the help page in the browser.
  required final VoidCallback onHelp,

  /// Opens the About window.
  required final VoidCallback onAbout,

  /// Closes the window, which exits the application.
  required final VoidCallback onExit,
});

/// The More button and the menu it opens: the commands used occasionally.
///
/// A flat list of items with icons, in groups parted by lines. Picking an item closes the menu.
/// An item shows its shortcut, but the key itself is bound by the window, which is where focus
/// lives.
class const OverflowMenu({
  super.key,

  /// What each item does.
  required final OverflowCallbacks callbacks,
}) extends StatelessWidget {
  /// The line between two groups of items, with less air around it than a divider has on a page.
  static const _separator = Divider(height: 8);

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        // Save the image to a file
        MenuItemButton(
          leadingIcon: const Icon(Symbols.save),
          trailingIcon: const _ShortcutHint(strings.saveAsShortcut),
          onPressed: callbacks.onSaveAs,
          child: const Text(strings.saveAsLabel),
        ),

        // Copy the image to the clipboard
        MenuItemButton(
          leadingIcon: const Icon(Symbols.content_copy),
          trailingIcon: const _ShortcutHint(strings.copyShortcut),
          onPressed: callbacks.onCopy,
          child: const Text(strings.copyLabel),
        ),

        _separator,

        // Hide the bars and show the image alone
        MenuItemButton(
          leadingIcon: const Icon(Symbols.fullscreen),
          trailingIcon: const _ShortcutHint(strings.showcaseShortcut),
          onPressed: callbacks.onShowcase,
          child: const Text(strings.showcaseLabel),
        ),

        _separator,

        // Help on the website
        MenuItemButton(
          leadingIcon: const Icon(Symbols.help),
          trailingIcon: const _ShortcutHint(strings.helpShortcut),
          onPressed: callbacks.onHelp,
          child: const Text(strings.helpLabel),
        ),

        // About the application
        MenuItemButton(
          leadingIcon: const Icon(Symbols.info),
          onPressed: callbacks.onAbout,
          child: const Text(strings.aboutLabel),
        ),

        // Exit the application
        MenuItemButton(
          leadingIcon: const Icon(Symbols.close),
          onPressed: callbacks.onExit,
          child: const Text(strings.exitLabel),
        ),
      ],

      // The More button that anchors the menu
      builder: (context, controller, child) => IconButton(
        icon: const Icon(Symbols.more_horiz),
        tooltip: strings.moreTooltip,
        onPressed: controller.isOpen ? controller.close : controller.open,
      ),
    );
  }
}

/// The keys of a menu item, drawn fainter than its label and clear of it.
///
/// Goes in an item's trailing slot, since Material's own shortcut text can be neither.
class const _ShortcutHint(final String keys) extends StatelessWidget {
  /// The least room between the longest label and its keys.
  static const _gap = 24.0;

  @override
  Widget build(BuildContext context) {
    // Faded from the row's own colour, so a disabled row fades its keys with its label
    final color = DefaultTextStyle.of(context).style.color;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: _gap),
      child: Text(
        keys,
        style: TextStyle(color: color?.withValues(alpha: color.a * 0.65)),
      ),
    );
  }
}
