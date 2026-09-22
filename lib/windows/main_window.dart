// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

// The windowing API is still internal, so opening a window needs implementation imports.
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:ffi' show Pointer, Void, nullptr;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/_window.dart';
import 'package:flutter/src/widgets/_window_win32.dart';

import 'package:material_ui/material_ui.dart';

import 'package:thumbico_core/thumbico_core.dart';

import '../common/sampled_runner.dart';
import '../common/settings.dart' as settings;
import '../common/shortcuts.dart' as shortcuts;
import '../common/size_limit.dart';
import '../common/strings.dart' as strings;
import '../common/theme.dart';
import '../common/urls.dart' as urls;
import '../common/window_title.dart';
import '../services/copy_image.dart';
import '../services/file_dialogs.dart';
import '../services/file_drop.dart';
import '../services/open_url.dart';
import '../services/save_image.dart';
import '../services/thumbico_service.dart';
import '../services/window_placement.dart';
import '../widgets/overflow_menu.dart';
import '../widgets/shortcut_scope.dart';
import '../widgets/showcase_view.dart';
import '../widgets/size_field.dart';
import '../widgets/status_bar.dart';
import '../widgets/thumbico_canvas.dart';
import '../widgets/toolbar.dart';
import 'about_window.dart';

/// The main window of the application.
class const MainWindow({super.key}) extends StatefulWidget {
  /// The smallest the window can be made.
  ///
  /// Wide enough for the toolbar with a path field still worth reading and for the status bar's
  /// panes, and tall enough for the options flyout, which is drawn inside the window.
  static const minimumSize = Size(540, 420);

  /// [minimumSize] in the form the window controller takes it.
  static final _constraints = BoxConstraints(
    minWidth: minimumSize.width,
    minHeight: minimumSize.height,
  );

  // Constructing the controller is what creates the native window.
  //
  // The constraints are set a second time because this SDK's Windows engine keeps the ones given
  // at creation for the view only: the window's own copy, which answers Windows when it asks for
  // the smallest size, is stored by the setter alone. Without the second call the minimum size
  // is ignored. Remove it when the engine stores the creation constraints on the window.
  static final _controller = _restored(
    WindowController(
      size: const Size(800, 600),
      constraints: _constraints,
      title: strings.mainWindowTitle,
      delegate: _MainWindowControllerDelegate(),
    )..setConstraints(_constraints),
  );

  /// Puts [controller]'s window, still hidden, where the last run left it; a first run has
  /// nothing saved, and the window keeps the size above where Windows places it.
  static WindowController _restored(WindowController controller) {
    final saved = WindowPlacement.tryFrom(
      left: settings.windowLeft.value,
      top: settings.windowTop.value,
      width: settings.windowWidth.value,
      height: settings.windowHeight.value,
      maximized: settings.windowMaximized.value,
    );
    if (saved != null && controller is WindowControllerWin32) {
      applyWindowPlacement(controller.windowHandle, saved);
      if (saved.maximized) {
        unawaited(maximizeWhenShown(controller.windowHandle, () => controller.setMaximized(true)));
      }
    }
    return controller;
  }

  /// Writes where the window is to the settings. Call while the window still exists.
  static void _savePlacement() {
    final placement = switch (_controller) {
      final WindowControllerWin32 controller => readWindowPlacement(controller.windowHandle),
      _ => null,
    };
    if (placement == null) {
      return;
    }
    settings.windowLeft.value = placement.left;
    settings.windowTop.value = placement.top;
    settings.windowWidth.value = placement.width;
    settings.windowHeight.value = placement.height;
    settings.windowMaximized.value = placement.maximized;
    settings.save();
  }

  /// Returns a [WindowEntry] for the main window.
  ///
  /// Call once, after the binding is initialized: the first call creates the native window.
  static WindowEntry windowEntry() {
    // Each window gets its own MaterialApp, which is what gives text fields their localizations
    // and tooltips their overlay
    return WindowEntry(
      controller: _controller,
      builder: (context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: strings.appName,
        // Both themes, so that the app follows the Windows light or dark setting by itself
        theme: appTheme(),
        darkTheme: appTheme(.dark),
        home: const MainWindow(),
      ),
    );
  }

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  /// What transparent pixels are flattened onto when a copy or a save cannot keep them.
  ///
  /// White in the dark theme as well, since the image leaves the app for a document.
  static const _background = Color(0xFFFFFFFF);

  /// The path field's text, owned here so that Showcase mode can take the toolbar away.
  final _path = TextEditingController();

  /// The path field's focus, so that a shortcut can put the caret there.
  final _pathFocus = FocusNode();

  /// The size field's text, starting from the size the last run ended on.
  final _size = TextEditingController(text: settings.sizeText.value);

  /// The image on the canvas and what the shell said about it; null until the first read.
  LoadedThumbico? _thumbico;

  /// What the status bar says; a problem is marked as one, so the bar can show it as one.
  ///
  /// Nothing at start, since the canvas already shows the ways to open an item.
  StatusMessage _message = .none;

  /// Whether the bars are hidden and the image shown alone. Never remembered between runs.
  var _showcase = false;

  /// What the overflow menu's items do and show; Save As and Copy are only offered while there is
  /// an image.
  OverflowMenuData get _overflowMenuData => OverflowMenuData(
    onSaveAs: _thumbico == null ? null : _saveAs,
    onCopy: _thumbico == null ? null : _copy,
    checkerboard: settings.checkerboard.value,
    onCheckerboardChanged: _setCheckerboard,
    onShowcase: _toggleShowcase,
    onHelp: _help,
    onAbout: _about,
    onExit: _exit,
  );

  /// The native window, so a dialog can be owned by it and stay in front.
  static Pointer<Void> get _handle => switch (MainWindow._controller) {
    final WindowControllerWin32 controller => controller.windowHandle,
    _ => nullptr,
  };

  /// What each shortcut does; the same handlers the buttons and menu items call.
  Map<ShortcutActivator, VoidCallback> get _shortcutBindings => {
    shortcuts.openFile: _openFile,
    shortcuts.openFolder: _openFolder,
    shortcuts.refresh: _read,
    shortcuts.focusPath: _focusPath,
    shortcuts.saveAs: _saveAs,
    shortcuts.copy: _copy,
    shortcuts.help: _help,
    shortcuts.bigger: _bigger,
    shortcuts.biggerNumpad: _bigger,
    shortcuts.smaller: _smaller,
    shortcuts.smallerNumpad: _smaller,
    shortcuts.showcase: _toggleShowcase,
    // Escape is taken only while there is a mode to leave
    if (_showcase) shortcuts.exitShowcase: _exitShowcase,
  };

  /// Puts the caret in the path field with the whole path selected, ready to be replaced.
  ///
  /// Exits Showcase mode first, since the field is hidden there; the focus request is deferred
  /// by the framework until the field is back in the tree.
  void _focusPath() {
    _exitShowcase();
    _pathFocus.requestFocus();
    _path.selection = TextSelection(baseOffset: 0, extentOffset: _path.text.length);
  }

  /// Enters Showcase mode, or leaves it.
  void _toggleShowcase() => setState(() => _showcase = !_showcase);

  /// Leaves Showcase mode if it is on, and does nothing otherwise.
  void _exitShowcase() {
    if (_showcase) {
      setState(() => _showcase = false);
    }
  }

  /// Drops on the window; listening is what makes the window take them.
  late final StreamSubscription<List<String>> _drops;

  @override
  void initState() {
    super.initState();
    // One item is shown at a time, so of several dropped together only the first is read
    _drops = fileDrops(_handle).listen((paths) => _open(paths.first));
  }

  /// Asks for a file in the Windows dialog and reads what comes back.
  void _openFile() => _open(pickFile(_handle));

  /// Asks for a folder in the Windows dialog and reads what comes back.
  void _openFolder() => _open(pickFolder(_handle));

  /// Puts a picked or dropped path in the field and reads it; a cancelled dialog changes nothing.
  void _open(String? path) {
    if (path == null) {
      return;
    }
    _path.text = path;
    _read();
  }

  /// Reads run one at a time; requests during a read collapse into one more read afterwards.
  ///
  /// Every read looks at the fields and the modes when it starts, so a burst of steps or
  /// toggles ends with one read of the final state and the image agrees with the field.
  late final _reads = SampledRunner(_readNow);

  /// Asks for a read of the item in the path field at the size in the size field.
  void _read() => _reads.request();

  /// The read itself; called only through [_reads].
  Future<void> _readNow() async {
    final size = ThumbicoSize.tryParse(_size.text);
    if (size == null) {
      setState(() => _message = const .error(strings.invalidSize));
      return;
    }
    // A size past the maximum is refused like text that is not a size, however it arrived:
    // typed, or restored from a settings file written before there was a maximum
    if (exceedsMaximum(size)) {
      setState(() => _message = .error(_largestSizeMessage));
      return;
    }
    // The field settles to the one format however the size was typed
    _size.text = size.format();
    settings.sizeText.value = _size.text;

    try {
      final thumbico = await loadThumbico(
        _path.text,
        size,
        source: settings.source.value,
        options: settings.options.value,
      );
      if (!mounted) {
        thumbico.image.dispose();
        return;
      }
      _thumbico?.image.dispose();
      setState(() {
        _thumbico = thumbico;
        _message = .none;
      });
      // The title names the item on screen, so a failed read leaves the last one's name there
      MainWindow._controller.setTitle(windowTitle(_path.text));
    } on ThumbicoException catch (e) {
      setState(() => _message = .error(_describe(e)));
    } on ArgumentError {
      setState(() => _message = const StatusMessage(strings.openOrDropFirst));
    }
  }

  /// Asks for the next size up.
  void _bigger() => _step((size) => size.scaled(SizeField.stepFactor));

  /// Asks for the next size down.
  void _smaller() => _step((size) => size.scaled(1 / SizeField.stepFactor));

  /// Replaces the size in the field with [next] of it, stopping at the maximum, and reads.
  ///
  /// Text that is not a size is left alone, so the read reports it as it would for Enter.
  void _step(ThumbicoSize Function(ThumbicoSize size) next) {
    final size = ThumbicoSize.tryParse(_size.text);
    if (size != null) {
      final wanted = next(size);
      final stepped = fittedToMaximum(wanted);
      // Nothing to read again, and at the maximum a held key would read the largest image
      // over and over
      if (stepped == size) {
        if (wanted != size) {
          setState(() => _message = .error(_largestSizeMessage));
        }
        return;
      }
      _size.text = stepped.format();
    }
    _read();
  }

  /// What the status bar says when a size past the maximum is asked for.
  String get _largestSizeMessage => '${strings.largestSizeIs} ${maximumSize.format()}.';

  /// Draws the image at the display's scale, or at real pixels.
  ///
  /// Only how the image is drawn changes, so nothing is read again.
  void _setScaleToDisplay(bool value) => setState(() => settings.scaleToDisplay.value = value);

  /// Draws the checkerboard behind the image, or leaves the canvas bare.
  ///
  /// Only what is behind the image changes, so nothing is read again.
  void _setCheckerboard(bool value) => setState(() => settings.checkerboard.value = value);

  /// Asks the shell for another source, and reads at once so the effect is visible.
  void _setSource(ThumbicoSource source) {
    setState(() => settings.source.value = source);
    _read();
  }

  /// Turns a shell option on or off, and reads at once so the effect is visible.
  void _toggleOption(ThumbicoOption option, bool isOn) {
    final options = {...settings.options.value};
    if (isOn) {
      options.add(option);
    } else {
      options.remove(option);
    }
    setState(() => settings.options.value = options);
    _read();
  }

  /// Asks where to save the image, writes it there, and says how it went in the status bar.
  Future<void> _saveAs() async {
    final thumbico = _thumbico;
    if (thumbico == null) {
      return;
    }
    final path = await pickSavePath(_handle, suggestedFileName(_path.text, thumbico.info.size));
    if (path == null || !mounted) {
      return;
    }
    final result = await saveImage(thumbico.image, path, _background);
    if (!mounted) {
      return;
    }
    setState(() {
      _message = switch (result) {
        Saved() => StatusMessage('${strings.savedTo} $path'),
        UnknownFormat() => const .error(strings.unknownSaveFormat),
        TooLargeForIco() => const .error(strings.tooLargeForIco),
        WriteFailed(:final reason) => .error('${strings.couldNotSave} $reason'),
      };
    });
  }

  /// Copies the image, flattened onto the canvas background, and says so in the status bar.
  Future<void> _copy() async {
    final image = _thumbico?.image;
    if (image == null) {
      return;
    }
    final copied = await copyImage(image, _background);
    if (mounted) {
      setState(
        () => _message = copied
            ? const StatusMessage(strings.copied)
            : const .error(strings.couldNotCopy),
      );
    }
  }

  /// Opens the help page in the browser, or says in the status bar that it could not.
  Future<void> _help() => _openInBrowser(urls.help);

  /// Opens [url] in the browser, or says in the status bar that it could not.
  Future<void> _openInBrowser(String url) async {
    final opened = await openUrl(url);
    if (!opened && mounted) {
      setState(() => _message = const .error(strings.couldNotOpenBrowser));
    }
  }

  /// Opens the About window over this one, which it blocks until it is closed.
  void _about() => AboutWindow.open(context, MainWindow._controller, onOpenUrl: _openInBrowser);

  /// Closes the window, which exits the application, as the close button does.
  ///
  /// Destroying the controller sends no close request, so the placement is saved from here too.
  void _exit() {
    MainWindow._savePlacement();
    MainWindow._controller.destroy();
  }

  /// What the status bar says for a failed read.
  String _describe(ThumbicoException e) => switch (e.failure) {
    ThumbicoFailure.itemNotFound => '${strings.itemNotFound}: ${e.path}',
    ThumbicoFailure.noThumbnail => '${strings.noThumbnail}: ${e.path}',
    ThumbicoFailure.shellError => '${strings.shellError}: ${e.path} (${e.hresultHex})',
  };

  @override
  void dispose() {
    _drops.cancel();
    _path.dispose();
    _pathFocus.dispose();
    _size.dispose();
    _reads.dispose();
    _thumbico?.image.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvas = ThumbicoCanvas(
      image: _thumbico?.image,
      scaleToDisplay: settings.scaleToDisplay.value,
      checkerboard: settings.checkerboard.value,
    );

    return ShortcutScope(
      bindings: _shortcutBindings,
      child: Material(
        child: Column(
          children: [
            // The toolbar, hidden in Showcase mode
            if (!_showcase)
              Toolbar(
                path: _path,
                pathFocus: _pathFocus,
                size: _size,
                onBigger: _bigger,
                onSmaller: _smaller,
                scaleToDisplay: settings.scaleToDisplay.value,
                onScaleToDisplayChanged: _setScaleToDisplay,
                onOpenFile: _openFile,
                onOpenFolder: _openFolder,
                onRefresh: _read,
                source: settings.source.value,
                options: settings.options.value,
                onSourceChanged: _setSource,
                onOptionToggled: _toggleOption,
                overflowMenuData: _overflowMenuData,
              ),

            // The image, alone with a way back while the bars are hidden
            Expanded(
              child: _showcase ? ShowcaseView(onExit: _exitShowcase, child: canvas) : canvas,
            ),

            // The status bar, hidden in Showcase mode
            if (!_showcase) StatusBar(message: _message, info: _thumbico?.info),
          ],
        ),
      ),
    );
  }
}

/// Saves the window's placement when it is asked to close, and exits the application when it
/// is destroyed, however it was closed.
class _MainWindowControllerDelegate with WindowControllerDelegate {
  @override
  void onWindowCloseRequested(WindowController controller) {
    // The last moment the window's handle is good; once destroyed it cannot be asked
    MainWindow._savePlacement();
    super.onWindowCloseRequested(controller);
  }

  @override
  void onWindowDestroyed() {
    super.onWindowDestroyed();
    ServicesBinding.instance.exitApplication(ui.AppExitType.required);
  }
}
