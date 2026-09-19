#include "file_drop.h"

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <flutter_windows.h>
#include <shellapi.h>
#include <windows.h>

#include <memory>
#include <string>

#include "utils.h"

namespace {

using Channel = flutter::MethodChannel<flutter::EncodableValue>;

// Lives as long as the process, like the engine it talks through.
std::unique_ptr<Channel> channel;

// Reads the paths out of a drop and releases it.
flutter::EncodableList TakePaths(HDROP drop) {
  flutter::EncodableList paths;
  const UINT count = ::DragQueryFileW(drop, 0xFFFFFFFF, nullptr, 0);
  for (UINT i = 0; i < count; ++i) {
    // Sized per path, so a long path is not cut at MAX_PATH
    const UINT length = ::DragQueryFileW(drop, i, nullptr, 0);
    std::wstring path(length + 1, L'\0');
    ::DragQueryFileW(drop, i, path.data(), length + 1);
    path.resize(length);
    paths.emplace_back(Utf8FromUtf16(path.c_str()));
  }
  ::DragFinish(drop);
  return paths;
}

// Sees every message of every top-level window the engine creates.
bool OnTopLevelWindowProc(HWND hwnd, UINT message, WPARAM wparam,
                          LPARAM lparam, void* user_data, LRESULT* result) {
  if (message != WM_DROPFILES) {
    return false;
  }
  flutter::EncodableMap arguments{
      {flutter::EncodableValue("window"),
       flutter::EncodableValue(static_cast<int64_t>(
           reinterpret_cast<intptr_t>(hwnd)))},
      {flutter::EncodableValue("paths"),
       flutter::EncodableValue(TakePaths(reinterpret_cast<HDROP>(wparam)))},
  };
  channel->InvokeMethod(
      "dropped", std::make_unique<flutter::EncodableValue>(arguments));
  *result = 0;
  return true;
}

}  // namespace

void RegisterFileDrop(flutter::FlutterEngine* engine) {
  channel = std::make_unique<Channel>(
      engine->messenger(), "file_drop",
      &flutter::StandardMethodCodec::GetInstance());
  ::FlutterDesktopPluginRegistrarRegisterTopLevelWindowProcDelegate(
      engine->GetRegistrarForPlugin("FileDrop"), OnTopLevelWindowProc,
      nullptr);
}
