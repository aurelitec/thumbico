// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

@TestOn('windows')
library;

import 'package:test/test.dart';
import 'package:thumbico_core/thumbico_core.dart';

void main() {
  group('ThumbicoException', () {
    test('classifies a missing file as itemNotFound', () {
      final e = ThumbicoException(
        hresult: 0x80070002 - 0x100000000,
        path: r'C:\missing.txt',
        operation: 'SHCreateItemFromParsingName',
      );
      expect(e.failure, ThumbicoFailure.itemNotFound);
      expect(e.hresultHex, '0x80070002');
    });

    test('classifies a missing path as itemNotFound', () {
      final e = ThumbicoException(
        hresult: 0x80070003 - 0x100000000,
        path: r'C:\missing\file.txt',
        operation: 'SHCreateItemFromParsingName',
      );
      expect(e.failure, ThumbicoFailure.itemNotFound);
    });

    test('classifies a failed extraction as noThumbnail', () {
      final e = ThumbicoException(
        hresult: 0x8004B200 - 0x100000000,
        path: r'C:\Windows\notepad.exe',
        operation: 'IShellItemImageFactory.GetImage',
      );
      expect(e.failure, ThumbicoFailure.noThumbnail);
      expect(e.hresultHex, '0x8004B200');
    });

    test('classifies anything else as shellError', () {
      final e = ThumbicoException(
        hresult: 0x80004005 - 0x100000000,
        path: r'C:\x',
        operation: 'IShellItemImageFactory.GetImage',
      );
      expect(e.failure, ThumbicoFailure.shellError);
      expect(e.hresultHex, '0x80004005');
    });

    test('accepts the unsigned form of an HRESULT too', () {
      final e = ThumbicoException(
        hresult: 0x8004B200,
        path: r'C:\x',
        operation: 'IShellItemImageFactory.GetImage',
      );
      expect(e.failure, ThumbicoFailure.noThumbnail);
      expect(e.hresultHex, '0x8004B200');
    });

    test('message and toString name the operation, path, and code', () {
      final e = ThumbicoException(
        hresult: 0x8004B200 - 0x100000000,
        path: r'C:\Windows\notepad.exe',
        operation: 'IShellItemImageFactory.GetImage',
      );
      expect(
        e.message,
        'IShellItemImageFactory.GetImage failed for "C:\\Windows\\notepad.exe" with 0x8004B200',
      );
      expect(e.toString(), 'ThumbicoException: ${e.message}');
    });
  });
}
