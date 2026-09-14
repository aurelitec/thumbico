// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'package:flutter_test/flutter_test.dart';
import 'package:thumbico/common/strings.dart' as strings;
import 'package:thumbico_core/thumbico_core.dart';

void main() {
  test('every source has a label', () {
    expect(strings.sourceLabels.keys, unorderedEquals(ThumbicoSource.values));
  });

  test('every shell option has a label', () {
    expect(strings.optionLabels.keys, unorderedEquals(ThumbicoOption.values));
  });
}
