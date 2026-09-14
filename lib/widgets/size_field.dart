// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter/services.dart';

import 'package:material_ui/material_ui.dart';

import 'package:thumbico_core/thumbico_core.dart';

import '../common/strings.dart' as strings;

/// The size field: a typed size, Enter to read, and a list of the standard sizes.
///
/// A picked standard size is written to the field in the one format and submitted
/// at once, so a pick behaves like typing the size and pressing Enter.
class const SizeField({
  super.key,

  /// The field's text, owned by the window.
  required final TextEditingController controller,

  /// Called when the user presses Enter in the field or picks a standard size.
  required final VoidCallback onSubmitted,
}) extends StatelessWidget {
  /// Every icon size the Windows shell itself uses, then doubled twice for thumbnails.
  static const presets = [16, 24, 32, 48, 64, 96, 128, 256, 512, 1024, 2048];

  /// Wide enough for the longest entry and the chevron.
  static const _width = 150.0;

  /// The arrow keys as a text field normally has them.
  ///
  /// The anchor binds the plain arrows to focus traversal for its menu, which
  /// would take them from the field; this map sits closer to the field and wins.
  static const _editingShortcuts = <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.arrowLeft): ExtendSelectionByCharacterIntent(
      forward: false,
      collapseSelection: true,
    ),
    SingleActivator(LogicalKeyboardKey.arrowRight): ExtendSelectionByCharacterIntent(
      forward: true,
      collapseSelection: true,
    ),
    SingleActivator(LogicalKeyboardKey.arrowUp): ExtendSelectionVerticallyToAdjacentLineIntent(
      forward: false,
      collapseSelection: true,
    ),
    SingleActivator(LogicalKeyboardKey.arrowDown): ExtendSelectionVerticallyToAdjacentLineIntent(
      forward: true,
      collapseSelection: true,
    ),
  };

  /// Puts a standard size in the field in the one format, then submits it.
  void _pick(int side) {
    controller.text = ThumbicoSize.square(side).format();
    onSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        // The standard sizes, in the format the field settles to
        for (final side in presets)
          MenuItemButton(
            onPressed: () => _pick(side),
            child: Text(ThumbicoSize.square(side).format()),
          ),
      ],

      // The field, with the chevron that opens the list
      builder: (context, menu, child) => SizedBox(
        width: _width,
        child: Shortcuts(
          shortcuts: _editingShortcuts,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              isDense: true,
              border: const OutlineInputBorder(),
              contentPadding: const .symmetric(horizontal: 8, vertical: 8),
              hintText: strings.sizeHint,
              // The decoration reserves a 48-pixel box for its suffix by default,
              // which would make this field taller than the path field
              suffixIconConstraints: const BoxConstraints.tightFor(width: 32, height: 32),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_drop_down),
                tooltip: strings.standardSizesTooltip,
                padding: .zero,
                constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                onPressed: menu.isOpen ? menu.close : menu.open,
              ),
            ),
            onSubmitted: (_) => onSubmitted(),
          ),
        ),
      ),
    );
  }
}
