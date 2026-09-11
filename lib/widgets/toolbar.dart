// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:material_ui/material_ui.dart';

import '../common/strings.dart' as strings;

/// The window's toolbar: the path, the size, and the button that asks the shell again.
class const Toolbar({
  super.key,
  required final TextEditingController path,
  required final TextEditingController size,
  required final VoidCallback onRefresh,
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
            Expanded(
              child: TextField(
                controller: path,
                decoration: fieldDecoration.copyWith(hintText: strings.pathHint),
                onSubmitted: (_) => onRefresh(),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              child: TextField(
                controller: size,
                decoration: fieldDecoration.copyWith(hintText: strings.sizeHint),
                onSubmitted: (_) => onRefresh(),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: strings.refreshTooltip,
              onPressed: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}
