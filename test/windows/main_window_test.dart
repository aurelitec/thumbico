// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:thumbico/widgets/overflow_menu.dart';
import 'package:thumbico/widgets/status_bar.dart';
import 'package:thumbico/widgets/thumbico_canvas.dart';
import 'package:thumbico/widgets/toolbar.dart';
import 'package:thumbico/windows/main_window.dart';
import 'package:thumbico_core/thumbico_core.dart';

import '../widget_host.dart';

void main() {
  disableWindowingForTests();

  // Widths are the subject here, and the test font draws every character as a full square,
  // about twice the real width. Windows' own font is loaded under the name a test's theme
  // asks for, since a test counts as Android.
  setUpAll(() async {
    final font = File(r'C:\Windows\Fonts\segoeui.ttf').readAsBytes();
    await (FontLoader('Roboto')..addFont(font.then((bytes) => ByteData.sublistView(bytes)))).load();
  });

  /// The window's bars around the canvas before any image, as the window lays them out.
  Widget bars(TextEditingController path, TextEditingController size, FocusNode pathFocus) {
    return host(
      Column(
        children: [
          Toolbar(
            path: path,
            pathFocus: pathFocus,
            size: size,
            onBigger: () {},
            onSmaller: () {},
            scaleToDisplay: false,
            onScaleToDisplayChanged: (_) {},
            onOpenFile: () {},
            onOpenFolder: () {},
            onRefresh: () {},
            source: ThumbicoSource.auto,
            options: const {},
            onSourceChanged: (_) {},
            onOptionToggled: (_, _) {},
            overflowCallbacks: OverflowCallbacks(
              onShowcase: () {},
              onHelp: () {},
              onAbout: () {},
              onExit: () {},
            ),
          ),
          const Expanded(child: ThumbicoCanvas()),

          // The widest the panes get: five-digit sizes and the longer kind
          const StatusBar(
            message: StatusMessage('The shell could not render this item'),
            info: ThumbicoInfo(
              size: ThumbicoSize(16384, 16384),
              requestedSize: ThumbicoSize(16384, 16384),
              isIcon: false,
            ),
          ),
        ],
      ),
    );
  }

  testWidgets('at the minimum size the bars fit and the path field is still useful', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = MainWindow.minimumSize;
    addTearDown(tester.view.reset);
    final path = TextEditingController();
    final size = TextEditingController(text: '2048 x 2048');
    final pathFocus = FocusNode();
    addTearDown(path.dispose);
    addTearDown(size.dispose);
    addTearDown(pathFocus.dispose);

    // An overflow anywhere in the bars or the empty canvas fails the test as an exception
    await tester.pumpWidget(bars(path, size, pathFocus));

    expect(tester.getSize(find.byType(TextField).first).width, greaterThanOrEqualTo(150));
  });

  testWidgets('at the minimum size the options flyout shows whole', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = MainWindow.minimumSize;
    addTearDown(tester.view.reset);
    final path = TextEditingController();
    final size = TextEditingController(text: '256 x 256');
    final pathFocus = FocusNode();
    addTearDown(path.dispose);
    addTearDown(size.dispose);
    addTearDown(pathFocus.dispose);

    await tester.pumpWidget(bars(path, size, pathFocus));
    await tester.tap(find.byTooltip('Options'));
    await tester.pumpAndSettle();

    // The last row is inside the window, so the card did not have to scroll
    final lastRow = tester.getRect(find.byType(CheckboxMenuButton).last);
    expect(lastRow.bottom, lessThanOrEqualTo(MainWindow.minimumSize.height - 8));
  });
}
