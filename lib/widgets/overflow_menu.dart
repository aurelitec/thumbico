// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:material_ui/material_ui.dart';

import '../common/strings.dart' as strings;

/// What the window does for each item of the overflow menu.
///
/// One bundle travels from the window through the toolbar to the menu, so a new item adds a
/// field here rather than a parameter on every widget in between.
class const OverflowCallbacks({
  /// Called when the user picks Copy; null while there is nothing to copy, which disables the item.
  final VoidCallback? onCopy,

  /// Called when the user picks Help.
  required final VoidCallback onHelp,

  /// Called when the user picks Exit.
  required final VoidCallback onExit,
});

/// The More button and the menu it opens: the commands used occasionally.
///
/// A flat list of items with icons. Picking an item closes the menu.
class const OverflowMenu({
  super.key,

  /// What each item does.
  required final OverflowCallbacks callbacks,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        // Copy the image to the clipboard
        MenuItemButton(
          leadingIcon: const Icon(Icons.content_copy),
          onPressed: callbacks.onCopy,
          child: const Text(strings.copyLabel),
        ),

        // Help on the website
        MenuItemButton(
          leadingIcon: const Icon(Icons.help_outline),
          onPressed: callbacks.onHelp,
          child: const Text(strings.helpLabel),
        ),

        // Exit the application
        MenuItemButton(
          leadingIcon: const Icon(Icons.close),
          onPressed: callbacks.onExit,
          child: const Text(strings.exitLabel),
        ),
      ],

      // The More button that anchors the menu
      builder: (context, controller, child) => IconButton(
        icon: const Icon(Icons.more_horiz),
        tooltip: strings.moreTooltip,
        onPressed: controller.isOpen ? controller.close : controller.open,
      ),
    );
  }
}
