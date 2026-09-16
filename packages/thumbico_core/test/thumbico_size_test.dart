// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

@TestOn('windows')
library;

import 'package:test/test.dart';
import 'package:thumbico_core/thumbico_core.dart';

void main() {
  group('ThumbicoSize.tryParse', () {
    const accepted = <String, ThumbicoSize>{
      '256': ThumbicoSize(256, 256),
      ' 256 ': ThumbicoSize(256, 256),
      '256x160': ThumbicoSize(256, 160),
      '256X160': ThumbicoSize(256, 160),
      '256 x 160': ThumbicoSize(256, 160),
      '256 \u00D7 160': ThumbicoSize(256, 160),
      '1x1': ThumbicoSize(1, 1),
      '20000x20000': ThumbicoSize(20000, 20000),
    };

    for (final entry in accepted.entries) {
      test('accepts "${entry.key}"', () {
        expect(ThumbicoSize.tryParse(entry.key), entry.value);
      });
    }

    const rejected = <String>[
      '',
      '   ',
      '0',
      '0x256',
      '256x0',
      '-256',
      '+256',
      '256.0',
      '1,024',
      'x256',
      '256x',
      '256x160x5',
      'abc',
      '256 by 160',
    ];

    for (final text in rejected) {
      test('rejects "$text"', () {
        expect(ThumbicoSize.tryParse(text), isNull);
      });
    }
  });

  group('ThumbicoSize', () {
    test('format writes the form tryParse reads back', () {
      const size = ThumbicoSize(256, 160);
      expect(size.format(), '256 x 160');
      expect(ThumbicoSize.tryParse(size.format()), size);
    });

    test('square constructor sets both dimensions', () {
      const size = ThumbicoSize.square(48);
      expect(size.width, 48);
      expect(size.height, 48);
      expect(size.isSquare, isTrue);
      expect(const ThumbicoSize(48, 32).isSquare, isFalse);
    });

    test('has value equality', () {
      expect(const ThumbicoSize(1, 2), const ThumbicoSize(1, 2));
      expect(const ThumbicoSize(1, 2).hashCode, const ThumbicoSize(1, 2).hashCode);
      expect(const ThumbicoSize(1, 2), isNot(const ThumbicoSize(2, 1)));
    });

    test('toString matches format', () {
      expect(const ThumbicoSize(300, 200).toString(), '300 x 200');
    });

    test('scaled multiplies both dimensions and rounds to whole pixels', () {
      expect(const ThumbicoSize(256, 160).scaled(1.25), const ThumbicoSize(320, 200));
      expect(const ThumbicoSize(341, 100).scaled(1.25), const ThumbicoSize(426, 125));
      expect(const ThumbicoSize(320, 200).scaled(1 / 1.25), const ThumbicoSize(256, 160));
    });

    test('scaled never goes below one pixel', () {
      expect(const ThumbicoSize(1, 3).scaled(0.5), const ThumbicoSize(1, 2));
      expect(const ThumbicoSize(1, 1).scaled(0.1), const ThumbicoSize(1, 1));
    });
  });
}
