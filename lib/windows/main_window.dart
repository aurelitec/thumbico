// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

// The windowing API is still internal, so opening a window needs implementation imports.
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: implementation_imports

import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/_window.dart';

import 'package:material_ui/material_ui.dart';

import 'package:thumbico_core/thumbico_core.dart';

import '../common/strings.dart' as strings;
import '../common/theme.dart';
import '../imaging/ui_image.dart';
import '../widgets/status_bar.dart';
import '../widgets/thumbico_canvas.dart';
import '../widgets/toolbar.dart';

/// The main window of the application.
class const MainWindow({super.key}) extends StatefulWidget {
  // Constructing the controller is what creates the native window
  static final _controller = WindowController(
    size: const Size(800, 600),
    title: strings.mainWindowTitle,
    delegate: _MainWindowControllerDelegate(),
  );

  /// Returns a [WindowEntry] for the main window. Call before `runWidget`.
  static WindowEntry windowEntry() {
    // Each window gets its own MaterialApp, which is what gives text fields
    // their localizations and tooltips their overlay.
    return WindowEntry(
      controller: _controller,
      builder: (context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: strings.appName,
        theme: appTheme(),
        home: const MainWindow(),
      ),
    );
  }

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  final _path = TextEditingController();
  final _size = TextEditingController(text: '256');

  ui.Image? _image;
  ThumbicoImage? _result;
  ThumbicoSize? _requested;
  var _message = strings.enterPath;

  /// Asks the shell for the item in the path field at the size in the size field.
  Future<void> _read() async {
    final size = ThumbicoSize.tryParse(_size.text);
    if (size == null) {
      setState(() => _message = strings.invalidSize);
      return;
    }

    try {
      final result = await readThumbicoAsync(_path.text, size);
      final image = await toUiImage(result);
      if (!mounted) {
        image.dispose();
        return;
      }
      _image?.dispose();
      setState(() {
        _image = image;
        _result = result;
        _requested = size;
        _message = '';
      });
    } on ThumbicoException catch (e) {
      setState(() => _message = _describe(e));
    } on ArgumentError {
      setState(() => _message = strings.enterPath);
    }
  }

  String _describe(ThumbicoException e) => switch (e.failure) {
    ThumbicoFailure.itemNotFound => '${strings.itemNotFound}: ${e.path}',
    ThumbicoFailure.noThumbnail => '${strings.noThumbnail}: ${e.path}',
    ThumbicoFailure.shellError => '${strings.shellError}: ${e.path} (${e.hresultHex})',
  };

  @override
  void dispose() {
    _path.dispose();
    _size.dispose();
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Toolbar(path: _path, size: _size, onRefresh: _read),
          Expanded(child: ThumbicoCanvas(image: _image)),
          StatusBar(message: _message, requested: _requested, image: _result),
        ],
      ),
    );
  }
}

class _MainWindowControllerDelegate with WindowControllerDelegate {
  @override
  void onWindowDestroyed() {
    super.onWindowDestroyed();
    ServicesBinding.instance.exitApplication(ui.AppExitType.required);
  }
}
