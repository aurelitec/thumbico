// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:test/test.dart';
import 'package:thumbico_core/thumbico_core.dart';

void main() {
  const info = ThumbicoInfo(
    size: ThumbicoSize(256, 192),
    requestedSize: ThumbicoSize.square(256),
    isIcon: false,
  );

  test('is equal to another with the same facts', () {
    const same = ThumbicoInfo(
      size: ThumbicoSize(256, 192),
      requestedSize: ThumbicoSize.square(256),
      isIcon: false,
    );
    expect(info, same);
    expect(info.hashCode, same.hashCode);
  });

  test('differs when any fact differs', () {
    expect(
      info,
      isNot(
        const ThumbicoInfo(
          size: ThumbicoSize(256, 192),
          requestedSize: ThumbicoSize.square(256),
          isIcon: true,
        ),
      ),
    );
    expect(
      info,
      isNot(
        const ThumbicoInfo(
          size: ThumbicoSize(256, 256),
          requestedSize: ThumbicoSize.square(256),
          isIcon: false,
        ),
      ),
    );
    expect(
      info,
      isNot(
        const ThumbicoInfo(
          size: ThumbicoSize(256, 192),
          requestedSize: ThumbicoSize.square(512),
          isIcon: false,
        ),
      ),
    );
  });

  test('describes itself for test output and logs', () {
    expect(info.toString(), '256 x 192, requested 256 x 256, thumbnail');
  });
}
