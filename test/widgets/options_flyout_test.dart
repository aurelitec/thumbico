// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:thumbico/widgets/options_flyout.dart';
import 'package:thumbico_core/thumbico_core.dart';

import '../widget_host.dart';

void main() {
  disableWindowingForTests();

  Widget flyout({
    ThumbicoSource source = ThumbicoSource.auto,
    Set<ThumbicoOption> options = const {},
    ValueChanged<ThumbicoSource>? onSourceChanged,
    void Function(ThumbicoOption option, bool isOn)? onOptionToggled,
  }) {
    return host(
      OptionsFlyout(
        source: source,
        options: options,
        onSourceChanged: onSourceChanged ?? (_) {},
        onOptionToggled: onOptionToggled ?? (_, _) {},
      ),
    );
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Options'));
    await tester.pumpAndSettle();
  }

  testWidgets('the Options button opens the flyout with the sources and every option', (
    tester,
  ) async {
    await tester.pumpWidget(flyout());
    expect(find.byType(SwitchListTile), findsNothing);

    await open(tester);

    expect(find.text('Best'), findsOneWidget);
    expect(find.text('Thumbnail'), findsOneWidget);
    expect(find.text('Icon'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsNWidgets(ThumbicoOption.values.length));
  });

  testWidgets('picking a source reports it', (tester) async {
    ThumbicoSource? picked;
    await tester.pumpWidget(flyout(onSourceChanged: (source) => picked = source));
    await open(tester);

    await tester.tap(find.text('Icon'));
    await tester.pump();

    expect(picked, ThumbicoSource.iconOnly);
  });

  testWidgets('switching an option on reports it and keeps the flyout open', (tester) async {
    final toggled = <(ThumbicoOption, bool)>[];
    await tester.pumpWidget(
      flyout(onOptionToggled: (option, isOn) => toggled.add((option, isOn))),
    );
    await open(tester);

    await tester.tap(find.text('Crop to square'));
    await tester.pumpAndSettle();

    expect(toggled, [(ThumbicoOption.cropToSquare, true)]);
    expect(find.byType(SwitchListTile), findsNWidgets(ThumbicoOption.values.length));
  });

  testWidgets('switching an option that is on reports it off', (tester) async {
    final toggled = <(ThumbicoOption, bool)>[];
    await tester.pumpWidget(
      flyout(
        options: const {ThumbicoOption.scaleUp},
        onOptionToggled: (option, isOn) => toggled.add((option, isOn)),
      ),
    );
    await open(tester);

    await tester.tap(find.text('Scale small images up'));
    await tester.pump();

    expect(toggled, [(ThumbicoOption.scaleUp, false)]);
  });

  testWidgets('the button carries a mark only when a mode is not at its default', (tester) async {
    bool marked() => tester.widget<Badge>(find.byType(Badge)).isLabelVisible;

    await tester.pumpWidget(flyout());
    expect(marked(), isFalse);

    await tester.pumpWidget(flyout(source: ThumbicoSource.thumbnailOnly));
    expect(marked(), isTrue);

    await tester.pumpWidget(flyout(options: const {ThumbicoOption.wideAspect}));
    expect(marked(), isTrue);
  });
}
