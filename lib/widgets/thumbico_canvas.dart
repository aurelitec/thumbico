// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../common/assets.dart' as assets;
import '../common/strings.dart' as strings;
import 'two_axis_scroll_view.dart';

/// Shows a shell image at its real pixel size, centred, scrolling when it does not fit.
class const ThumbicoCanvas({
  super.key,

  /// The image to show; while there is none, the canvas shows the ways to open an item.
  final ui.Image? image,

  /// Whether to draw the image at the display's scale instead of one image pixel per screen pixel.
  final bool scaleToDisplay = false,

  /// Whether the checkerboard is drawn behind the image; off, the canvas colour shows through.
  final bool checkerboard = true,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final image = this.image;
    if (image == null) {
      return const _EmptyCanvas();
    }

    final isLight = Theme.of(context).brightness == .light;

    return TwoAxisScrollView(
      child: CustomPaint(
        // The greys of an image editor's checkerboard; both dark ones are lighter than the dark
        // canvas, so the image's bounds still show
        painter: checkerboard
            ? _Checkerboard(
                first: isLight ? const Color(0xFFFFFFFF) : const Color(0xFF2B2B2B),
                second: isLight ? const Color(0xFFCCCCCC) : const Color(0xFF3A3A3A),
              )
            : null,
        // The display's scale is Flutter's resolution-aware asset mechanism: an image with that
        // scale draws one image pixel per device pixel. A scale of one draws it as the display
        // draws everything else.
        child: RawImage(
          image: image,
          scale: scaleToDisplay ? 1 : MediaQuery.devicePixelRatioOf(context),
          filterQuality: FilterQuality.none,
        ),
      ),
    );
  }
}

/// What the canvas shows while there is no image: the app icon as a grey watermark, and a hint.
class const _EmptyCanvas() extends StatelessWidget {
  /// The size the icon is drawn at, large enough to read as a watermark rather than an image.
  static const _iconSize = 256.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isLight = theme.brightness == .light;

    return Center(
      child: Column(
        mainAxisSize: .min,
        children: [
          // The app icon in grey, since colour on the canvas means an image
          ColorFiltered(
            colorFilter: .saturation(0),
            child: Image.asset(
              assets.appIcon,
              width: _iconSize,
              height: _iconSize,
              // Grey stands out twice as far from a dark canvas as from white at one opacity, so
              // the dark theme fades it by half to match
              opacity: AlwaysStoppedAnimation(isLight ? 0.4 : 0.2),
              filterQuality: .medium,
              excludeFromSemantics: true,
            ),
          ),

          // The ways in
          const SizedBox(height: 16),
          Text(
            strings.emptyCanvasHint,
            textAlign: .center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Alternating squares behind the image, so transparency is visible.
class const _Checkerboard({
  /// The colour of the first square, and of every other one after it.
  required final Color first,

  /// The colour of the squares in between.
  required final Color second,
}) extends CustomPainter {
  /// The side of one square.
  static const _square = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Squares are drawn whole, so without this the last ones reach past the image's edge
    canvas.clipRect(Offset.zero & size);

    final firstPaint = Paint()..color = first;
    final secondPaint = Paint()..color = second;
    for (var y = 0.0; y < size.height; y += _square) {
      for (var x = 0.0; x < size.width; x += _square) {
        final even = ((x / _square).floor() + (y / _square).floor()).isEven;
        canvas.drawRect(Rect.fromLTWH(x, y, _square, _square), even ? firstPaint : secondPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_Checkerboard oldDelegate) =>
      first != oldDelegate.first || second != oldDelegate.second;
}
