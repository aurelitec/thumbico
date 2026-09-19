// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:material_ui/material_ui.dart';

/// Scrolls one child both ways, with a scroll bar along each edge, and centres it when it fits.
///
/// The framework has no such view for a single child, so this nests two one-way views. It is to
/// be replaced when the framework, or a well-supported package, offers one.
class const TwoAxisScrollView({
  super.key,

  /// What is scrolled, at its own size.
  required final Widget child,
}) extends StatefulWidget {
  @override
  State<TwoAxisScrollView> createState() => _TwoAxisScrollViewState();
}

class _TwoAxisScrollViewState extends State<TwoAxisScrollView> {
  /// The position of the outer view, which scrolls sideways.
  final _horizontal = ScrollController();

  /// The position of the inner view, which scrolls up and down.
  final _vertical = ScrollController();

  @override
  void dispose() {
    _horizontal.dispose();
    _vertical.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      // The platform's own bars are turned off: the inner view is as wide as the child, so its
      // bar would lie at the child's far edge, out of sight
      builder: (context, constraints) => ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),

        // Both bars wrap both views, so each lies along an edge of the whole view
        child: Scrollbar(
          controller: _horizontal,
          thumbVisibility: true,
          child: Scrollbar(
            controller: _vertical,
            thumbVisibility: true,
            // The inner view's notifications arrive from one scroll view deeper
            notificationPredicate: (notification) => notification.depth == 1,
            child: SingleChildScrollView(
              controller: _horizontal,
              scrollDirection: .horizontal,
              child: SingleChildScrollView(
                controller: _vertical,
                // At least as large as the view, so a child that fits is centred in it
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                    minHeight: constraints.maxHeight,
                  ),
                  child: Center(child: widget.child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
