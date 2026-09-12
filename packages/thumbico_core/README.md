# thumbico_core

Reads the thumbnail or icon of any shell item through the Windows shell, at any requested size. The engine behind Thumbico.

Pure Dart, Windows only. No Flutter dependency, so the same code serves the Thumbico GUI and a command-line tool.

## Usage

```dart
import 'package:thumbico_core/thumbico_core.dart';

// From a UI isolate: runs in its own isolate, so the shell's extraction never blocks the UI.
final image = await readThumbicoAsync(r'C:\Windows\explorer.exe', const ThumbicoSize.square(256));

// From a command-line tool, where blocking is fine:
final same = readThumbico(r'C:\Windows\explorer.exe', const ThumbicoSize.square(256));

print(image.info); // 256 x 256, requested 256 x 256, icon
```

`ThumbicoSource` chooses between the thumbnail, the icon, or the best available (the default). `ThumbicoOption` values map one-to-one to the shell's `SIIGBF` flags. `ThumbicoSize.tryParse` reads `256`, `256x160`, or `256 x 160` the same way for every frontend.

Shell failures throw `ThumbicoException`, with `failure` (`itemNotFound`, `noThumbnail`, `shellError`), the `hresult`, and the normalized `path`. Empty paths and dimensions outside 1 to 2^31 - 1 throw `ArgumentError`. There is no other size limit: the shell will happily produce a 20000x20000 image in thirteen seconds, so a frontend applies its own maximum.

## Pixels

`ThumbicoImage` is two things: `info`, what the shell said about the item (`size`, `requestedSize`, `isIcon`), and `pixels`, the buffer. Keep `info` and let the image go once the pixels have been used; the facts stay small.

`pixels` is straight (non-premultiplied) alpha, BGRA byte order, four bytes per pixel, rows top-down, no padding, so the length is `info.size.width * info.size.height * 4`.

- `package:image`: `img.Image.fromBytes(width: w, height: h, bytes: pixels.buffer, numChannels: 4, order: img.ChannelOrder.bgra)`.
- Flutter: premultiply the alpha into a copy first, then `ui.decodeImageFromPixels(copy, w, h, ui.PixelFormat.bgra8888, callback)`. Flutter's raw formats are premultiplied.

## Consuming from another repository

```yaml
dependencies:
  thumbico_core:
    git:
      url: https://github.com/aurelitec/thumbico.git
      path: packages/thumbico_core
      ref: thumbico_core-v0.1.0
```
