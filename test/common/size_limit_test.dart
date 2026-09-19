// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter_test/flutter_test.dart';
import 'package:thumbico/common/size_limit.dart';
import 'package:thumbico_core/thumbico_core.dart';

void main() {
  test('the largest side is 8192', () {
    expect(maximumSide, 8192);
  });

  test('a size exceeds the maximum when either side does', () {
    expect(exceedsMaximum(const ThumbicoSize(8192, 8192)), isFalse);
    expect(exceedsMaximum(const ThumbicoSize(8193, 16)), isTrue);
    expect(exceedsMaximum(const ThumbicoSize(16, 8193)), isTrue);
  });

  test('a size within the maximum is left as it is', () {
    expect(fittedToMaximum(const ThumbicoSize(8192, 100)), const ThumbicoSize(8192, 100));
  });

  test('a size past the maximum is brought back to it, keeping its shape', () {
    expect(fittedToMaximum(const ThumbicoSize(10240, 10240)), const ThumbicoSize(8192, 8192));
    expect(fittedToMaximum(const ThumbicoSize(10000, 5000)), const ThumbicoSize(8192, 4096));
    expect(fittedToMaximum(const ThumbicoSize(5000, 10000)), const ThumbicoSize(4096, 8192));
  });

  test('a very thin size keeps at least one pixel', () {
    expect(fittedToMaximum(const ThumbicoSize(100000, 1)), const ThumbicoSize(8192, 1));
  });
}
