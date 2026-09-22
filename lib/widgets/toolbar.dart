// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import 'package:thumbico_core/thumbico_core.dart';

import '../common/strings.dart' as strings;
import 'options_flyout.dart';
import 'overflow_menu.dart';
import 'size_field.dart';

/// The window's toolbar: the open buttons, the path, the size, refresh, the options flyout, and
/// the overflow menu.
class const Toolbar({
  super.key,

  /// The path field's text, owned by the window.
  required final TextEditingController path,

  /// The path field's focus, which the window uses to put the caret there on its shortcut.
  required final FocusNode pathFocus,

  /// The size field's text, owned by the window.
  required final TextEditingController size,

  /// Called when the user asks for the next size up.
  required final VoidCallback onBigger,

  /// Called when the user asks for the next size down.
  required final VoidCallback onSmaller,

  /// Whether the image is drawn at the display's scale rather than at real pixels.
  required final bool scaleToDisplay,

  /// Called with the new choice when the user picks the other scale.
  required final ValueChanged<bool> onScaleToDisplayChanged,

  /// Called when the user asks for the file dialog.
  required final VoidCallback onOpenFile,

  /// Called when the user asks for the folder dialog.
  required final VoidCallback onOpenFolder,

  /// Called when the user asks for a read, by the button or by Enter in either field.
  required final VoidCallback onRefresh,

  /// The source currently asked of the shell.
  required final ThumbicoSource source,

  /// The shell options currently on.
  required final Set<ThumbicoOption> options,

  /// Called with the new source when the user picks one.
  required final ValueChanged<ThumbicoSource> onSourceChanged,

  /// Called with the option and its new state when the user checks or unchecks it.
  required final void Function(ThumbicoOption option, bool isOn) onOptionToggled,

  /// What each item of the overflow menu does.
  required final OverflowMenuData overflowMenuData,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const fieldDecoration = InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );

    return Material(
      color: theme.colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // The two dialogs, separate because Windows has none that picks both kinds
            IconButton(
              icon: const Icon(Symbols.draft),
              tooltip: strings.openFileTooltip,
              onPressed: onOpenFile,
            ),
            IconButton(
              icon: const Icon(Symbols.folder),
              tooltip: strings.openFolderTooltip,
              onPressed: onOpenFolder,
            ),
            const SizedBox(width: 4),

            // The universal input, and the only control that changes width
            Expanded(
              child: TextField(
                controller: path,
                focusNode: pathFocus,
                decoration: fieldDecoration.copyWith(hintText: strings.pathHint),
                onSubmitted: (_) => onRefresh(),
              ),
            ),
            const SizedBox(width: 8),

            // The size asked for, with the sizes behind its chevron
            SizeField(
              controller: size,
              onSubmitted: onRefresh,
              onBigger: onBigger,
              onSmaller: onSmaller,
              scaleToDisplay: scaleToDisplay,
              onScaleToDisplayChanged: onScaleToDisplayChanged,
            ),
            const SizedBox(width: 4),

            // Ask again for the same item at the same size
            IconButton(
              icon: const Icon(Symbols.refresh),
              tooltip: strings.refreshTooltip,
              onPressed: onRefresh,
            ),
            const SizedBox(width: 4),

            // The modes that change what the shell returns, and the occasional commands
            OptionsFlyout(
              source: source,
              options: options,
              onSourceChanged: onSourceChanged,
              onOptionToggled: onOptionToggled,
            ),
            OverflowMenu(menuData: overflowMenuData),
          ],
        ),
      ),
    );
  }
}
