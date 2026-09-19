// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:material_ui/material_ui.dart';

/// Scrolls one child both ways, with a scroll bar along each edge, and centres it when it fits.
///
/// The framework has no such view for a single child, so this nests two one-way views. It is to
/// be replaced when the framework, or a well-supported package, offers one.
class const TwoAxisScrollView({
  super.key,

  /// The view's two positions, owned and disposed by the caller, which can scroll through it.
  required final TwoAxisScrollController controller,

  /// What is scrolled, at its own size.
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      // The platform's own bars are turned off: the inner view is as wide as the child, so its
      // bar would lie at the child's far edge, out of sight
      builder: (context, constraints) => ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),

        // Both bars wrap both views, so each lies along an edge of the whole view
        child: Scrollbar(
          controller: controller.horizontal,
          thumbVisibility: true,
          child: Scrollbar(
            controller: controller.vertical,
            thumbVisibility: true,
            // The inner view's notifications arrive from one scroll view deeper
            notificationPredicate: (notification) => notification.depth == 1,
            child: SingleChildScrollView(
              controller: controller.horizontal,
              scrollDirection: .horizontal,
              child: SingleChildScrollView(
                controller: controller.vertical,
                // At least as large as the view, so a child that fits is centred in it
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                    minHeight: constraints.maxHeight,
                  ),
                  child: Center(child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The two positions of a [TwoAxisScrollView], and the steps a key scrolls it by.
class TwoAxisScrollController {
  /// How far a line step goes, in logical pixels. The framework's own value.
  static const _lineStep = 50.0;

  /// How much of the view a page step goes. The framework's own value.
  static const _pageFraction = 0.8;

  /// How long a step glides, so that a held key scrolls smoothly. The framework's own value.
  static const _glide = Duration(milliseconds: 100);

  /// The position of the outer view, which scrolls sideways.
  final horizontal = ScrollController();

  /// The position of the inner view, which scrolls up and down.
  final vertical = ScrollController();

  /// Scrolls one step towards [direction], a line or most of a view, stopping at the child's
  /// edge. Does nothing while no view is attached.
  void scroll(AxisDirection direction, {ScrollIncrementType type = .line}) {
    final controller = switch (axisDirectionToAxis(direction)) {
      .horizontal => horizontal,
      .vertical => vertical,
    };
    if (!controller.hasClients) {
      return;
    }

    final position = controller.position;
    final step = switch (type) {
      .line => _lineStep,
      .page => _pageFraction * position.viewportDimension,
    };
    final forward = direction == .right || direction == .down;
    position.moveTo(
      position.pixels + (forward ? step : -step),
      duration: _glide,
      curve: Curves.easeInOut,
    );
  }

  /// Releases both positions; call it from the owner's own dispose.
  void dispose() {
    horizontal.dispose();
    vertical.dispose();
  }
}
