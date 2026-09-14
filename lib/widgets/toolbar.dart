// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:material_ui/material_ui.dart';

import 'package:thumbico_core/thumbico_core.dart';

import '../common/strings.dart' as strings;
import 'options_flyout.dart';
import 'size_field.dart';

/// The window's toolbar: the open buttons, the path, the size, refresh, and the options flyout.
class const Toolbar({
  super.key,
  required final TextEditingController path,
  required final TextEditingController size,
  required final VoidCallback onOpenFile,
  required final VoidCallback onOpenFolder,
  required final VoidCallback onRefresh,
  required final ThumbicoSource source,
  required final Set<ThumbicoOption> options,
  required final ValueChanged<ThumbicoSource> onSourceChanged,
  required final void Function(ThumbicoOption option, bool isOn) onOptionToggled,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const fieldDecoration = InputDecoration(
      isDense: true,
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );

    return Material(
      color: theme.colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.file_open),
              tooltip: strings.openFileTooltip,
              onPressed: onOpenFile,
            ),
            IconButton(
              icon: const Icon(Icons.folder_open),
              tooltip: strings.openFolderTooltip,
              onPressed: onOpenFolder,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: path,
                decoration: fieldDecoration.copyWith(hintText: strings.pathHint),
                onSubmitted: (_) => onRefresh(),
              ),
            ),
            const SizedBox(width: 8),
            SizeField(controller: size, onSubmitted: onRefresh),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: strings.refreshTooltip,
              onPressed: onRefresh,
            ),
            const SizedBox(width: 4),
            OptionsFlyout(
              source: source,
              options: options,
              onSourceChanged: onSourceChanged,
              onOptionToggled: onOptionToggled,
            ),
          ],
        ),
      ),
    );
  }
}
