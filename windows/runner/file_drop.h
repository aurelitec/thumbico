#ifndef RUNNER_FILE_DROP_H_
#define RUNNER_FILE_DROP_H_

#include <flutter/flutter_engine.h>

// Sends the paths of files dropped on any of the engine's windows to Dart.
//
// A window takes drops only after Dart has turned them on for it. Call once,
// before the engine runs; the engine must outlive the message loop.
void RegisterFileDrop(flutter::FlutterEngine* engine);

#endif  // RUNNER_FILE_DROP_H_
