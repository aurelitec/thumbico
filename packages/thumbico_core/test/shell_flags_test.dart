// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

@TestOn('windows')
library;

import 'package:test/test.dart';
import 'package:thumbico_core/src/shell/shell_flags.dart';
import 'package:thumbico_core/thumbico_core.dart';
import 'package:win32/win32.dart';

void main() {
  group('shellFlagOf', () {
    const expected = <ThumbicoOption, int>{
      ThumbicoOption.allowLargerSize: 0x01,
      ThumbicoOption.inMemoryOnly: 0x02,
      ThumbicoOption.inCacheOnly: 0x10,
      ThumbicoOption.cropToSquare: 0x20,
      ThumbicoOption.wideAspect: 0x40,
      ThumbicoOption.iconBackground: 0x80,
      ThumbicoOption.scaleUp: 0x100,
    };

    for (final entry in expected.entries) {
      test('${entry.key.name} maps to 0x${entry.value.toRadixString(16)}', () {
        expect(shellFlagOf(entry.key), entry.value);
      });
    }

    test('covers every option', () {
      expect(expected.keys, containsAll(ThumbicoOption.values));
    });
  });

  group('toShellFlags', () {
    test('an explicit source with no options is just the source flag', () {
      expect(toShellFlags(ThumbicoSource.thumbnailOnly, const {}), SIIGBF_THUMBNAILONLY);
      expect(toShellFlags(ThumbicoSource.iconOnly, const {}), 0x04);
    });

    test('folds options with OR', () {
      expect(
        toShellFlags(ThumbicoSource.thumbnailOnly, const {
          ThumbicoOption.scaleUp,
          ThumbicoOption.cropToSquare,
        }),
        0x128,
      );
    });

    test('rejects auto, which the caller resolves', () {
      expect(() => toShellFlags(ThumbicoSource.auto, const {}), throwsArgumentError);
    });
  });
}
