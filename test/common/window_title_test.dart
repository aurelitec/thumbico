// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter_test/flutter_test.dart';
import 'package:thumbico/common/window_title.dart';

void main() {
  test('an item is named by the last part of its path', () {
    expect(windowTitle(r'C:\Windows\notepad.exe'), 'notepad.exe - Thumbico');
  });

  test('a trailing slash is dropped', () {
    expect(windowTitle(r'C:\Windows\'), 'Windows - Thumbico');
    expect(windowTitle('C:/Windows/System32/'), 'System32 - Thumbico');
  });

  test('a drive root has no last part and is named whole', () {
    expect(windowTitle(r'C:\'), r'C:\ - Thumbico');
  });

  test('a shell string has no last part and is named whole', () {
    expect(windowTitle('shell:Desktop'), 'shell:Desktop - Thumbico');
    expect(
      windowTitle('::{20D04FE0-3AEA-1069-A2D8-08002B30309D}'),
      '::{20D04FE0-3AEA-1069-A2D8-08002B30309D} - Thumbico',
    );
  });

  test('quotes around a pasted path do not reach the title', () {
    expect(windowTitle(r'"C:\My Folder\a b.txt"'), 'a b.txt - Thumbico');
  });

  // Windows clips the caption itself, so the longest name a file system allows is passed whole.
  test('a long name is not cut', () {
    final name = 'x' * 255;
    expect(windowTitle('C:\\Windows\\$name'), '$name - Thumbico');
  });
}
