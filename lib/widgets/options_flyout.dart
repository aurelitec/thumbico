// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:material_ui/material_ui.dart';

import 'package:thumbico_core/thumbico_core.dart';

import '../common/strings.dart' as strings;

/// The Options button and the flyout it opens: the source and the shell options.
///
/// The flyout closes on a click outside it or on Escape, never on a change. The
/// button carries a mark while any mode is away from its default.
class const OptionsFlyout({
  super.key,
  required final ThumbicoSource source,
  required final Set<ThumbicoOption> options,
  required final ValueChanged<ThumbicoSource> onSourceChanged,
  required final void Function(ThumbicoOption option, bool isOn) onOptionToggled,
}) extends StatelessWidget {
  static const _width = 300.0;

  bool get _isDefault => source == ThumbicoSource.auto && options.isEmpty;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: const MenuStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(8))),
      menuChildren: [
        SizedBox(
          width: _width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              for (final option in ThumbicoOption.values)
                SwitchListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(strings.optionLabels[option]!),
                  value: options.contains(option),
                  onChanged: (isOn) => onOptionToggled(option, isOn),
                ),
            ],
          ),
        ),
      ],
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
