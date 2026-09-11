// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

@TestOn('windows')
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:thumbico_core/thumbico_core.dart';

import 'fixtures.dart';

const notepad = r'C:\Windows\System32\notepad.exe';
const size256 = ThumbicoSize.square(256);

/// Allows for the shell's resampling when comparing a channel value.
Matcher near(int expected) => inInclusiveRange(expected - 4, expected + 4);

void main() {
  late Fixtures fixtures;

  setUpAll(() => fixtures = Fixtures.create());
  tearDownAll(() => fixtures.dispose());

  group('readThumbico with iconOnly', () {
    test('returns the requested square for an executable', () {
      final image = readThumbico(notepad, size256, source: ThumbicoSource.iconOnly);
      expect(image.width, 256);
      expect(image.height, 256);
      expect(image.rowStride, 256 * 4);
      expect(image.isIcon, isTrue);
      expect(image.requestedSize, size256);
      expect(image.pixels.length, 256 * 256 * 4);
    });

    test('preserves partial transparency', () {
      final image = readThumbico(notepad, size256, source: ThumbicoSource.iconOnly);
      var partial = 0;
      var opaque = 0;
      for (var i = 3; i < image.pixels.length; i += 4) {
        final alpha = image.pixels[i];
        if (alpha == 255) {
          opaque++;
        } else if (alpha > 0) {
          partial++;
        }
      }
      expect(opaque, greaterThan(0));
      expect(partial, greaterThan(0), reason: 'an icon has anti-aliased edges');
    });

    test('returns an icon file right side up with straight alpha', () {
      final image = readThumbico(
        fixtures.ico,
        const ThumbicoSize.square(32),
        source: ThumbicoSource.iconOnly,
      );
      expect(image.width, 32);
      expect(image.height, 32);

      // Lists, not records: expect applies nested matchers inside a list only.
      final (r1, g1, b1, a1) = pixelAt(image, 14, 8);
      expect([r1, g1, b1, a1], [near(220), near(0), near(0), 255], reason: 'top half is red');

      final (r2, g2, b2, a2) = pixelAt(image, 14, 24);
      expect([r2, g2, b2, a2], [near(0), near(0), near(220), 255], reason: 'bottom half is blue');

      final (r3, g3, b3, a3) = pixelAt(image, 1, 16);
      expect(g3, near(200), reason: 'straight alpha keeps the green at 200, not 100');
      expect(a3, near(128));
      expect([r3, b3], [near(0), near(0)]);

      final (_, _, _, a4) = pixelAt(image, 28, 16);
      expect(a4, 0, reason: 'right band is transparent');
    });

    test('works for a folder and a drive', () {
      expect(readThumbico(r'C:\Windows', size256, source: ThumbicoSource.iconOnly).width, 256);
      expect(readThumbico(r'C:\', size256, source: ThumbicoSource.iconOnly).width, 256);
    });
  });

  group('readThumbico with thumbnailOnly', () {
    test('keeps the aspect ratio and returns the image right side up', () {
      final image = readThumbico(fixtures.png, size256, source: ThumbicoSource.thumbnailOnly);
      expect(image.width, 256);
      expect(image.height, 192);
      expect(image.isIcon, isFalse);
      expect(image.pixels.length, 256 * 192 * 4);

      final w = image.width;
      final h = image.height;

      final (r1, g1, b1, a1) = pixelAt(image, w * 45 ~/ 100, h ~/ 4);
      expect([r1, g1, b1, a1], [near(220), near(0), near(0), 255], reason: 'top half is red');

      final (r2, g2, b2, a2) = pixelAt(image, w * 45 ~/ 100, h * 3 ~/ 4);
      expect([r2, g2, b2, a2], [near(0), near(0), near(220), 255], reason: 'bottom half is blue');

      final (_, g3, _, a3) = pixelAt(image, w * 7 ~/ 100, h ~/ 2);
      expect(g3, near(200), reason: 'straight alpha keeps the green at 200');
      expect(a3, near(128));

      final (_, _, _, a4) = pixelAt(image, w * 90 ~/ 100, h ~/ 2);
      expect(a4, 0, reason: 'right band is transparent');
    });

    test('does not exceed the source size', () {
      final image = readThumbico(
        fixtures.png,
        const ThumbicoSize.square(1024),
        source: ThumbicoSource.thumbnailOnly,
      );
      expect(image.width, 400);
      expect(image.height, 300);
    });

    test('throws noThumbnail for an item without a thumbnail handler', () {
      expect(
        () => readThumbico(fixtures.text, size256, source: ThumbicoSource.thumbnailOnly),
        throwsA(
          isA<ThumbicoException>()
              .having((e) => e.failure, 'failure', ThumbicoFailure.noThumbnail)
              .having((e) => e.hresultHex, 'hresultHex', '0x8004B200')
              .having((e) => e.path, 'path', fixtures.text),
        ),
      );
    });
  });

  group('readThumbico path handling', () {
    test('throws itemNotFound with the normalized absolute path', () {
      final missing = p.join(fixtures.directory.path, 'missing.png');
      expect(
        () => readThumbico(missing, size256, source: ThumbicoSource.iconOnly),
        throwsA(
          isA<ThumbicoException>()
              .having((e) => e.failure, 'failure', ThumbicoFailure.itemNotFound)
              .having((e) => e.path, 'path', missing),
        ),
      );
    });

    test('makes a relative path absolute before asking the shell', () {
      // The temp directory may sit on another drive, so a missing relative
      // path is used: the reported path proves what the shell was asked for.
      expect(
        () => readThumbico('missing.png', size256, source: ThumbicoSource.iconOnly),
        throwsA(
          isA<ThumbicoException>()
              .having((e) => e.failure, 'failure', ThumbicoFailure.itemNotFound)
              .having((e) => e.path, 'path', p.join(Directory.current.path, 'missing.png')),
        ),
      );
    });

    test('passes a shell namespace string through unchanged', () {
      // The parsing name of This PC.
      const thisPc = '::{20D04FE0-3AEA-1069-A2D8-08002B30309D}';
      final image = readThumbico(thisPc, size256, source: ThumbicoSource.iconOnly);
      expect(image.width, 256);
      expect(image.height, 256);
    });

    test('accepts forward slashes', () {
      final image = readThumbico(
        'C:/Windows/System32/notepad.exe',
        size256,
        source: ThumbicoSource.iconOnly,
      );
      expect(image.width, 256);
    });

    test('rejects an empty path', () {
      expect(() => readThumbico('  ', size256), throwsArgumentError);
    });
  });

  group('readThumbico with auto', () {
    test('returns the thumbnail when the item has one', () {
      final image = readThumbico(fixtures.png, size256);
      expect(image.isIcon, isFalse);
      expect(image.width, 256);
      expect(image.height, 192);
    });

    test('falls back to the icon when the item has no thumbnail', () {
      final image = readThumbico(fixtures.text, size256);
      expect(image.isIcon, isTrue);
      expect(image.width, 256);
      expect(image.height, 256);
    });

    test('falls back to the icon for an executable and a drive', () {
      expect(readThumbico(notepad, size256).isIcon, isTrue);
      expect(readThumbico(r'C:\', size256).isIcon, isTrue);
    });

    test('does not fall back for a missing item', () {
      final missing = p.join(fixtures.directory.path, 'missing.txt');
      expect(
        () => readThumbico(missing, size256),
        throwsA(
          isA<ThumbicoException>().having(
            (e) => e.failure,
            'failure',
            ThumbicoFailure.itemNotFound,
          ),
        ),
      );
    });
  });

  group('readThumbicoAsync', () {
    test('returns the same bytes as the synchronous call', () async {
      final sync = readThumbico(fixtures.png, size256);
      final async = await readThumbicoAsync(fixtures.png, size256);
      expect(async.width, sync.width);
      expect(async.height, sync.height);
      expect(async.isIcon, sync.isIcon);
      expect(async.requestedSize, sync.requestedSize);
      expect(async.pixels, sync.pixels);
    });

    test('rethrows a shell failure from the isolate', () {
      expect(
        readThumbicoAsync(fixtures.text, size256, source: ThumbicoSource.thumbnailOnly),
        throwsA(
          isA<ThumbicoException>()
              .having((e) => e.failure, 'failure', ThumbicoFailure.noThumbnail)
              .having((e) => e.hresultHex, 'hresultHex', '0x8004B200'),
        ),
      );
    });

    test('rejects bad arguments without spawning an isolate', () {
      expect(readThumbicoAsync('', size256), throwsArgumentError);
      expect(readThumbicoAsync(notepad, const ThumbicoSize(0, 1)), throwsArgumentError);
    });

    test('can run several reads at once', () async {
      final images = await Future.wait([
        readThumbicoAsync(notepad, size256),
        readThumbicoAsync(fixtures.png, size256),
        readThumbicoAsync(r'C:\Windows', size256),
      ]);
      expect(images.map((i) => i.width), [256, 256, 256]);
    });
  });

  group('readThumbico size validation', () {
    test('rejects a zero or negative dimension', () {
      expect(() => readThumbico(notepad, const ThumbicoSize(0, 16)), throwsArgumentError);
      expect(() => readThumbico(notepad, const ThumbicoSize(16, -1)), throwsArgumentError);
    });

    test('rejects a dimension beyond the 32-bit range', () {
      expect(
        () => readThumbico(notepad, const ThumbicoSize(16, 0x80000000)),
        throwsArgumentError,
      );
    });
  });
}
