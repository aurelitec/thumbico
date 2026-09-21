// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import '../common/strings.dart' as strings;

/// The image area while Showcase mode is on: the child alone, with a way back for the mouse.
///
/// A button that exits the mode floats in the top right corner and shows only while the
/// pointer is over the view, so a screenshot taken with the mouse elsewhere holds nothing but
/// the image.
class const ShowcaseView({
  super.key,

  /// Called when the user clicks the button that exits Showcase mode.
  required final VoidCallback onExit,

  /// What the view shows, normally the canvas.
  required final Widget child,
}) extends StatefulWidget {
  @override
  State<ShowcaseView> createState() => _ShowcaseViewState();
}

class _ShowcaseViewState extends State<ShowcaseView> {
  /// How long the exit button takes to appear or fade.
  static const _fade = Duration(milliseconds: 150);

  /// Whether the pointer is over the view, which is when the exit button shows.
  var _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Stack(
        fit: .expand,
        children: [
          // The image, filling the view
          widget.child,

          // The way back for the mouse, in the corner least likely to cover a centred image, and
          // far enough from the edge to clear the vertical scroll bar
          Positioned(
            top: 16,
            right: 16,
            child: IgnorePointer(
              ignoring: !_hovering,
              child: AnimatedOpacity(
                opacity: _hovering ? 1 : 0,
                duration: _fade,
                child: Tooltip(
                  message: strings.exitShowcaseTooltip,
                  child: FilledButton.tonalIcon(
                    icon: const Icon(Symbols.fullscreen_exit),
                    label: const Text(strings.exitShowcaseLabel),
                    onPressed: widget.onExit,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
