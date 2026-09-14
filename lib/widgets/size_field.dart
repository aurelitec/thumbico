// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter/services.dart';

import 'package:material_ui/material_ui.dart';

import 'package:thumbico_core/thumbico_core.dart';

import '../common/strings.dart' as strings;

/// The size field: a typed size, Enter to read, and a list of the standard sizes.
///
/// Built on the framework's combo box. A picked or highlighted standard size is
/// written to the field in the one format and submitted at once.
class const SizeField({
  super.key,

  /// The field's text, owned by the window.
  required final TextEditingController controller,

  /// Called when the user presses Enter in the field or picks a standard size.
  required final VoidCallback onSubmitted,
}) extends StatefulWidget {
  /// Every icon size the Windows shell itself uses, then doubled twice for thumbnails.
  static const presets = [16, 24, 32, 48, 64, 96, 128, 256, 512, 1024, 2048];

  /// Wide enough for the longest entry and the chevron.
  static const _width = 150.0;

  @override
  State<SizeField> createState() => _SizeFieldState();
}

class _SizeFieldState extends State<SizeField> {
  /// Tells the Enter handler whether the combo's own submit will fire.
  final _menu = MenuController();

  /// Submits on Enter while the list is closed, the one case the combo ignores.
  ///
  /// With the list open, the combo reports the typed or highlighted size itself
  /// through its selection callback. The key is left unhandled so that path runs.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final isEnter = event.logicalKey == .enter || event.logicalKey == .numpadEnter;
    if (event is KeyDownEvent && isEnter && !_menu.isOpen) {
      widget.onSubmitted();
    }
    return .ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _onKey,
      child: DropdownMenu<int>(
        controller: widget.controller,
        menuController: _menu,
        width: SizeField._width,
        requestFocusOnTap: true,
        enableFilter: false,
        enableSearch: false,
        hintText: strings.sizeHint,
        // The path field's dense look, and a suffix box that does not grow the field
        inputDecorationTheme: const InputDecorationThemeData(
          isDense: true,
          border: OutlineInputBorder(),
          contentPadding: .symmetric(horizontal: 8, vertical: 8),
          suffixIconConstraints: BoxConstraints.tightFor(width: 32, height: 32),
        ),

        // The standard sizes, in the format the field settles to
        dropdownMenuEntries: [
          for (final side in SizeField.presets)
            DropdownMenuEntry(value: side, label: ThumbicoSize.square(side).format()),
        ],

        // Null is the combo's word for typed text submitted with the list open;
        // either way the text is already in the controller
        onSelected: (_) => widget.onSubmitted(),
      ),
    );
  }
}
