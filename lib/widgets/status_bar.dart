// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import 'package:thumbico_core/thumbico_core.dart';

import '../common/strings.dart' as strings;

/// What the status bar says, and whether it reports a problem.
final class const StatusMessage(final String text, {final bool isError = false}) {
  /// A message that reports a problem, which the bar shows alone and marked.
  const new error(String text) : this(text, isError: true);

  /// Nothing to say.
  static const none = StatusMessage('');
}

/// The window's status bar: a message, then what was asked for and what came back.
///
/// A message that reports a problem takes the whole bar, as a Windows status bar does in its
/// simple mode: the panes describe the last image, and beside an error they would read as
/// its result.
class const StatusBar({
  super.key,
  final StatusMessage message = .none,

  /// What the last read returned, shown in the panes.
  final ThumbicoInfo? info,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final info = this.info;
    final panes = <String>[
      if (info != null && !message.isError) ...[
        '${strings.askedFor} ${info.requestedSize.format()}',
        '${strings.returned} ${info.size.format()}',
        info.isIcon ? strings.kindIcon : strings.kindThumbnail,
      ],
    ];

    return Material(
      color: message.isError ? colors.error : colors.surfaceContainer,
      child: SizedBox(
        height: 28,
        child: Row(
          children: [
            // The mark of a problem, so that it does not rest on colour alone
            if (message.isError)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Symbols.error, fill: 1, color: colors.onError),
              ),

            // The message, which gives way to the panes when the window is narrow
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  message.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: message.isError ? TextStyle(color: colors.onError) : null,
                ),
              ),
            ),

            // What the last read returned
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
