// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:thumbico/widgets/toolbar.dart';

import '../widget_host.dart';

void main() {
  disableWindowingForTests();

  testWidgets('the refresh button and Enter in either field ask for a read', (tester) async {
    final path = TextEditingController(text: r'C:\Windows');
    final size = TextEditingController(text: '256');
    addTearDown(path.dispose);
    addTearDown(size.dispose);
    var reads = 0;

    await tester.pumpWidget(host(Toolbar(path: path, size: size, onRefresh: () => reads++)));

    await tester.tap(find.byIcon(Icons.refresh));
    expect(reads, 1);

    await tester.enterText(find.byType(TextField).first, r'C:\');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(reads, 2);
    expect(path.text, r'C:\');

    await tester.enterText(find.byType(TextField).last, '512');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(reads, 3);
    expect(size.text, '512');
  });
}
