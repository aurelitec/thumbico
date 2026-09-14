// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:material_ui/material_ui.dart';

import 'package:thumbico_core/thumbico_core.dart';

import '../common/strings.dart' as strings;

/// The Options button and the flyout it opens: the source and the shell options.
///
/// The flyout closes on a click outside it or on Escape, never on a change. The button carries a
/// mark while any mode is away from its default.
class const OptionsFlyout({
  super.key,

  /// The source currently asked of the shell.
  required final ThumbicoSource source,

  /// The shell options currently on.
  required final Set<ThumbicoOption> options,

  /// Called with the new source when the user picks one.
  required final ValueChanged<ThumbicoSource> onSourceChanged,

  /// Called with the option and its new state when the user flips a switch.
  required final void Function(ThumbicoOption option, bool isOn) onOptionToggled,
}) extends StatelessWidget {
  static const _width = 300.0;

  /// Whether every mode is at its default, so the button needs no mark.
  bool get _isDefault => source == .auto && options.isEmpty;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: const MenuStyle(padding: WidgetStatePropertyAll(.all(8))),
      menuChildren: [
        SizedBox(
          width: _width,
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .stretch,
            children: [
              // The source, one row of mutually exclusive choices
              SegmentedButton<ThumbicoSource>(
                showSelectedIcon: false,
                segments: [
                  for (final value in ThumbicoSource.values)
                    ButtonSegment(value: value, label: Text(strings.sourceLabels[value]!)),
                ],
                selected: {source},
                onSelectionChanged: (selected) => onSourceChanged(selected.single),
              ),

              const SizedBox(height: 8),

              // The shell options, one switch per line
              for (final option in ThumbicoOption.values)
                SwitchListTile(
                  dense: true,
                  visualDensity: .compact,
                  title: Text(strings.optionLabels[option]!),
                  value: options.contains(option),
                  onChanged: (isOn) => onOptionToggled(option, isOn),
                ),
            ],
          ),
        ),
      ],

      // The Options button that anchors the flyout, marked while a mode is off its default
      builder: (context, controller, child) => Badge(
        isLabelVisible: !_isDefault,
        smallSize: 8,
        child: IconButton(
          icon: const Icon(Icons.tune),
          tooltip: strings.optionsTooltip,
          onPressed: controller.isOpen ? controller.close : controller.open,
        ),
      ),
    );
  }
}
