// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:ffi';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thumbico/services/file_drop.dart';

import '../widget_host.dart';

/// Delivers a call on the drop channel as the runner would.
Future<void> _send(String method, Object? arguments) async {
  const codec = StandardMethodCodec();
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
    fileDropChannelName,
    codec.encodeMethodCall(MethodCall(method, arguments)),
    (_) {},
  );
}

void main() {
  disableWindowingForTests();
  TestWidgetsFlutterBinding.ensureInitialized();

  // No real window: turning drops on for a null handle does nothing, and the runner's side is
  // played by the test.
  final window = Pointer<Void>.fromAddress(0);

  test('a drop on the window arrives as its paths, in order', () async {
    final drops = <List<String>>[];
    final subscription = fileDrops(window).listen(drops.add);

    await _send('dropped', {
      'window': 0,
      'paths': [r'C:\a.png', r'C:\folder', r'X:\'],
    });

    expect(drops, [
      [r'C:\a.png', r'C:\folder', r'X:\'],
    ]);
    await subscription.cancel();
  });

  test('a drop on another window is ignored', () async {
    final drops = <List<String>>[];
    final subscription = fileDrops(window).listen(drops.add);

    await _send('dropped', {
      'window': 1234,
      'paths': [r'C:\a.png'],
    });

    expect(drops, isEmpty);
    await subscription.cancel();
  });

  test('a drop with no paths and an unknown call are ignored', () async {
    final drops = <List<String>>[];
    final subscription = fileDrops(window).listen(drops.add);

    await _send('dropped', {'window': 0, 'paths': <String>[]});
    await _send('something else', null);

    expect(drops, isEmpty);
    await subscription.cancel();
  });

  test('nothing arrives after the listener is gone', () async {
    final drops = <List<String>>[];
    final subscription = fileDrops(window).listen(drops.add);
    await subscription.cancel();

    await _send('dropped', {
      'window': 0,
      'paths': [r'C:\a.png'],
    });

    expect(drops, isEmpty);
  });
}
