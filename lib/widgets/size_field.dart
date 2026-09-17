// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:material_ui/material_ui.dart';

import 'package:thumbico_core/thumbico_core.dart';

import '../common/strings.dart' as strings;

/// The size field: a typed size, Enter to read, and a chevron that opens the size flyout.
///
/// Nothing opens on a click in the field or on typing, as in a Windows combo box. The flyout
/// wraps only the chevron, so the field keeps its own keys. It holds the step buttons, the
/// display-scale choice, and the standard sizes.
class const SizeField({
  super.key,

  /// The field's text, owned by the window.
  required final TextEditingController controller,

  /// Called when the user presses Enter in the field or picks a standard size.
  required final VoidCallback onSubmitted,

  /// Called when the user asks for the next size up.
  required final VoidCallback onBigger,

  /// Called when the user asks for the next size down.
  required final VoidCallback onSmaller,

  /// Whether the image is drawn at the display's scale rather than at real pixels.
  required final bool scaleToDisplay,

  /// Called with the new choice when the user picks the other scale.
  required final ValueChanged<bool> onScaleToDisplayChanged,
}) extends StatelessWidget {
  /// Every icon size the Windows shell itself uses, then doubled twice for thumbnails.
  static const presets = [16, 24, 32, 48, 64, 96, 128, 256, 512, 1024, 2048];

  /// What Bigger multiplies the size by and Smaller divides it by: a nudge, not a jump.
  static const stepFactor = 1.25;

  /// Wide enough for the longest size and the chevron.
  static const _width = 150.0;

  /// The same width as the options flyout.
  static const _flyoutWidth = 300.0;

  /// Writes a standard size into the field in the one format, then submits as Enter does.
  void _pick(int side) {
    controller.text = ThumbicoSize.square(side).format();
    onSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: TextField(
        controller: controller,
        onSubmitted: (_) => onSubmitted(),
        decoration: InputDecoration(
          isDense: true,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          hintText: strings.sizeHint,
          // A chevron box that does not grow the field past the path field's height
          suffixIconConstraints: const BoxConstraints.tightFor(width: 32, height: 32),
          suffixIcon: MenuAnchor(
            style: const MenuStyle(padding: WidgetStatePropertyAll(.all(8))),
            menuChildren: [
              SizedBox(
                width: _flyoutWidth,
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .stretch,
                  children: [
                    // Stepping on the left, the display-scale toggle on the right
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          tooltip: strings.smallerTooltip,
                          onPressed: onSmaller,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: strings.biggerTooltip,
                          onPressed: onBigger,
                        ),
                        const Spacer(),
                        IconButton(
                          isSelected: scaleToDisplay,
                          icon: const Icon(Icons.monitor),
                          tooltip: strings.displayScaleTooltip,
                          onPressed: () => onScaleToDisplayChanged(!scaleToDisplay),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // The standard sizes, in the format the field settles to
                    for (final side in presets)
                      MenuItemButton(
                        onPressed: () => _pick(side),
                        child: Text(ThumbicoSize.square(side).format()),
                      ),
                  ],
                ),
              ),
            ],

            // The chevron that anchors the flyout; it does not flip while open
            builder: (context, menu, child) => IconButton(
              icon: const Icon(Icons.expand_more),
              tooltip: strings.sizesTooltip,
              onPressed: menu.isOpen ? menu.close : menu.open,
            ),
          ),
        ),
      ),
    );
  }
}
