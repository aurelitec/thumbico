// Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
// Licensed under the MIT License. See LICENSE file in the project root for more information.

import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

/// Shows a shell image at its real pixel size, centred, scrolling when it does not fit.
class const ThumbicoCanvas({super.key, final ui.Image? image}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final image = this.image;
    if (image == null) {
      return const SizedBox.expand();
    }

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: CustomPaint(
                painter: const _Checkerboard(),
                // The scale is Flutter's resolution-aware asset mechanism: an image
                // with the display's scale draws one image pixel per device pixel.
                child: RawImage(
                  image: image,
                  scale: MediaQuery.devicePixelRatioOf(context),
                  filterQuality: FilterQuality.none,
                ),
              ),
            ),
          ),
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
