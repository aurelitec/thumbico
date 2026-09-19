// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

/// Files, folders, and drives dropped on a window from Explorer or any other program.
///
/// The runner's side is `windows/runner/file_drop.cpp`, which sees the drop message of every
/// window the engine creates and reports it here.
library;

import 'dart:async';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:win32/win32.dart';

/// The name of the channel the runner reports drops on.
@visibleForTesting
const fileDropChannelName = 'file_drop';

const _channel = MethodChannel(fileDropChannelName);

/// The drops on [window], each as the paths of its items in the order the source gave them.
///
/// The window takes drops while the stream is listened to and refuses them again once the
/// subscription is cancelled. A window nobody listens for never takes any, which is what keeps
/// a dialog window out. One window at a time: a second listener would replace the first.
Stream<List<String>> fileDrops(Pointer<Void> window) {
  late final StreamController<List<String>> controller;

  Future<void> onCall(MethodCall call) async {
    if (call.method != 'dropped') {
      return;
    }
    final arguments = call.arguments as Map;
    final paths = (arguments['paths'] as List).cast<String>();
    if (arguments['window'] == window.address && paths.isNotEmpty) {
      controller.add(paths);
    }
  }

  controller = StreamController(
    onListen: () {
      _channel.setMethodCallHandler(onCall);
      DragAcceptFiles(HWND(window), true);
    },
    onCancel: () {
      DragAcceptFiles(HWND(window), false);
      _channel.setMethodCallHandler(null);
    },
  );
  return controller.stream;
}
