// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:thumbico/widgets/toolbar.dart';
import 'package:thumbico_core/thumbico_core.dart';

import '../widget_host.dart';

void main() {
  disableWindowingForTests();

  late TextEditingController path;
  late TextEditingController size;

  setUp(() {
    path = TextEditingController(text: r'C:\Windows');
    size = TextEditingController(text: '256');
    addTearDown(path.dispose);
    addTearDown(size.dispose);
  });

  testWidgets('the refresh button and Enter in either field ask for a read', (tester) async {
    var reads = 0;

    await tester.pumpWidget(
      host(
        Toolbar(
          path: path,
          size: size,
          onOpenFile: () {},
          onOpenFolder: () {},
          onRefresh: () => reads++,
          source: ThumbicoSource.auto,
          options: const {},
          onSourceChanged: (_) {},
          onOptionToggled: (_, _) {},
        ),
      ),
    );

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

  testWidgets('the open buttons ask for a file and for a folder', (tester) async {
    var files = 0;
    var folders = 0;

    await tester.pumpWidget(
      host(
        Toolbar(
          path: path,
          size: size,
          onOpenFile: () => files++,
          onOpenFolder: () => folders++,
          onRefresh: () {},
          source: ThumbicoSource.auto,
          options: const {},
          onSourceChanged: (_) {},
          onOptionToggled: (_, _) {},
        ),
      ),
    );

    await tester.tap(find.byTooltip('Open file'));
    expect(files, 1);
    expect(folders, 0);

    await tester.tap(find.byTooltip('Open folder'));
    expect(files, 1);
    expect(folders, 1);
  });

  testWidgets('the open buttons come before the path field', (tester) async {
    await tester.pumpWidget(
      host(
        Toolbar(
          path: path,
          size: size,
          onOpenFile: () {},
          onOpenFolder: () {},
          onRefresh: () {},
          source: ThumbicoSource.auto,
          options: const {},
          onSourceChanged: (_) {},
          onOptionToggled: (_, _) {},
        ),
      ),
    );

    final fileButton = tester.getCenter(find.byTooltip('Open file'));
    final folderButton = tester.getCenter(find.byTooltip('Open folder'));
    final pathField = tester.getCenter(find.byType(TextField).first);
    expect(fileButton.dx, lessThan(folderButton.dx));
    expect(folderButton.dx, lessThan(pathField.dx));
  });

  testWidgets('the Options button comes after the refresh button', (tester) async {
    await tester.pumpWidget(
      host(
        Toolbar(
          path: path,
          size: size,
          onOpenFile: () {},
          onOpenFolder: () {},
          onRefresh: () {},
          source: ThumbicoSource.auto,
          options: const {},
          onSourceChanged: (_) {},
          onOptionToggled: (_, _) {},
        ),
      ),
    );

    final refreshButton = tester.getCenter(find.byTooltip('Ask the shell again'));
    final optionsButton = tester.getCenter(find.byTooltip('Options'));
    expect(refreshButton.dx, lessThan(optionsButton.dx));
  });

  testWidgets('the size field offers the standard sizes', (tester) async {
    await tester.pumpWidget(
      host(
        Toolbar(
          path: path,
          size: size,
          onOpenFile: () {},
          onOpenFolder: () {},
          onRefresh: () {},
          source: ThumbicoSource.auto,
          options: const {},
          onSourceChanged: (_) {},
          onOptionToggled: (_, _) {},
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.arrow_drop_down).hitTestable());
    await tester.pumpAndSettle();

    expect(find.text('2048 x 2048').hitTestable(), findsOneWidget);
  });

  testWidgets('the size field is as tall as the path field', (tester) async {
    await tester.pumpWidget(
      host(
        Toolbar(
          path: path,
          size: size,
          onOpenFile: () {},
          onOpenFolder: () {},
          onRefresh: () {},
          source: ThumbicoSource.auto,
          options: const {},
          onSourceChanged: (_) {},
          onOptionToggled: (_, _) {},
        ),
      ),
    );

    final pathField = tester.getSize(find.byType(TextField).first);
    final sizeField = tester.getSize(find.byType(TextField).last);
    expect(sizeField.height, pathField.height);
  });
}
