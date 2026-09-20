// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

import 'package:thumbico_core/thumbico_core.dart';

import '../common/strings.dart' as strings;

/// The size field: a typed size, Enter to read, and a chevron that opens the size flyout.
///
/// Nothing opens on a click in the field or on typing, as in a Windows combo box. The flyout
/// wraps only the chevron, so the field keeps its own keys. It holds the step buttons, the
/// standard sizes, and, where the display scales at all, the display-scale choice.
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

  /// The side of the chevron button's highlight, which leaves room around it inside the field.
  static const _chevronSize = 24.0;

  /// The box at the field's end that holds the chevron, and that the flyout hangs from.
  static const _chevronBox = 32.0;

  /// The room inside the flyout's card, around its rows.
  static const _flyoutPadding = 8.0;

  /// Writes a standard size into the field in the one format, then submits as Enter does.
  void _pick(int side) {
    controller.text = ThumbicoSize.square(side).format();
    onSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    // Where the display does not scale, both choices draw the same pixels, so the toggle is gone
    final displayScales = MediaQuery.devicePixelRatioOf(context) != 1;

    return SizedBox(
      width: _width,
      child: TextField(
        controller: controller,
        onSubmitted: (_) => onSubmitted(),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          hintText: strings.sizeHint,
          // A chevron box that does not grow the field past the path field's height
          suffixIconConstraints: const BoxConstraints.tightFor(
            width: _chevronBox,
            height: _chevronBox,
          ),
          suffixIcon: MenuAnchor(
            // Moved left from the chevron to the field's own edge and made as wide as the field,
            // so the list hangs under the field as a combo box's does
            alignmentOffset: const Offset(_chevronBox - _width, 0),
            style: const MenuStyle(padding: WidgetStatePropertyAll(.all(_flyoutPadding))),
            menuChildren: [
              SizedBox(
                width: _width - 2 * _flyoutPadding,
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .stretch,
                  children: [
                    // Stepping on the left, the display-scale toggle on the right
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Symbols.remove),
                          tooltip: strings.smallerTooltip,
                          onPressed: onSmaller,
                        ),
                        IconButton(
                          icon: const Icon(Symbols.add),
                          tooltip: strings.biggerTooltip,
                          onPressed: onBigger,
                        ),
                        const Spacer(),
                        if (displayScales)
                          IconButton(
                            isSelected: scaleToDisplay,
                            icon: const Icon(Symbols.desktop_windows),
                            // Filled while on, the way the symbols mark a selected state
                            selectedIcon: const Icon(Symbols.desktop_windows, fill: 1),
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

            // The chevron that anchors the flyout; it does not flip while open. Its highlight is
            // smaller than the box it sits in, so it stays clear of the field's outline.
            builder: (context, menu, child) => Center(
              child: IconButton(
                style: IconButton.styleFrom(
                  minimumSize: const .square(_chevronSize),
                  maximumSize: const .square(_chevronSize),
                  padding: .zero,
                  visualDensity: .standard,
                  tapTargetSize: .shrinkWrap,
                ),
                icon: const Icon(Symbols.keyboard_arrow_down),
                tooltip: strings.sizesTooltip,
                onPressed: menu.isOpen ? menu.close : menu.open,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
