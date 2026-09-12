## 0.1.0

- `ThumbicoImage` is `info` and `pixels`; `ThumbicoInfo` holds `size`, `requestedSize`, and `isIcon`, so the facts can outlive the buffer. `rowStride` removed.
- Initial version: `readThumbico` and `readThumbicoAsync` over `IShellItemImageFactory`.
