// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:material_ui/material_ui.dart';

import 'package:thumbico_core/thumbico_core.dart';

import '../common/strings.dart' as strings;

/// The window's status bar: a message, then what was asked for and what came back.
class const StatusBar({super.key, final String message = '', final ThumbicoInfo? info})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = this.info;
    final panes = <String>[
      if (info != null) ...[
        '${strings.askedFor} ${info.requestedSize.format()}',
        '${strings.returned} ${info.size.format()}',
        info.isIcon ? strings.kindIcon : strings.kindThumbnail,
      ],
    ];

    return Material(
      color: theme.colorScheme.surfaceContainer,
      child: SizedBox(
        height: 28,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(message, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
            for (final pane in panes) ...[
              const VerticalDivider(width: 1, indent: 4, endIndent: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(pane, maxLines: 1),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
