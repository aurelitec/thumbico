// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import 'two_axis_scroll_view.dart';

/// Shows a shell image at its real pixel size, centred, scrolling when it does not fit.
class const ThumbicoCanvas({
  super.key,
  final ui.Image? image,

  /// The scroll positions, owned by the window so that its keys can scroll the image.
  required final TwoAxisScrollController scroll,

  /// Whether to draw the image at the display's scale instead of one image pixel per screen pixel.
  final bool scaleToDisplay = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final image = this.image;
    if (image == null) {
      return const SizedBox.expand();
    }

    return TwoAxisScrollView(
      controller: scroll,
      child: CustomPaint(
        painter: const _Checkerboard(),
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

/// Alternating squares behind the image, so transparency is visible.
class const _Checkerboard() extends CustomPainter {
  static const _square = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Squares are drawn whole, so without this the last ones reach past the image's edge
    canvas.clipRect(Offset.zero & size);

    final light = Paint()..color = const Color(0xFFFFFFFF);
    final dark = Paint()..color = const Color(0xFFCCCCCC);
    for (var y = 0.0; y < size.height; y += _square) {
      for (var x = 0.0; x < size.width; x += _square) {
        final even = ((x / _square).floor() + (y / _square).floor()).isEven;
        canvas.drawRect(Rect.fromLTWH(x, y, _square, _square), even ? light : dark);
      }
    }
  }

  @override
  bool shouldRepaint(_Checkerboard oldDelegate) => false;
}
