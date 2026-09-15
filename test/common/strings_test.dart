// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:thumbico/common/shortcuts.dart' as shortcuts;
import 'package:thumbico/common/strings.dart' as strings;
import 'package:thumbico_core/thumbico_core.dart';

import '../widget_host.dart';

void main() {
  disableWindowingForTests();

  test('every source has a label', () {
    expect(strings.sourceLabels.keys, unorderedEquals(ThumbicoSource.values));
  });

  test('every shell option has a label', () {
    expect(strings.optionLabels.keys, unorderedEquals(ThumbicoOption.values));
  });

  /// The text a menu item shows for [activator], which is the framework's own label for it.
  Future<String> label(WidgetTester tester, MenuSerializableShortcut activator) async {
    await tester.pumpWidget(
      host(MenuItemButton(shortcut: activator, onPressed: () {}, child: const Text('item'))),
    );
    final texts = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data);
    return texts.firstWhere((t) => t != 'item')!;
  }

  testWidgets('the toolbar tooltips end with the label the framework gives their shortcut', (
    tester,
  ) async {
    expect(strings.openFileTooltip, endsWith('(${await label(tester, shortcuts.openFile)})'));
    expect(strings.openFolderTooltip, endsWith('(${await label(tester, shortcuts.openFolder)})'));
    expect(strings.refreshTooltip, endsWith('(${await label(tester, shortcuts.refresh)})'));
  });
}
