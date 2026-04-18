import tauri/os

pub type Platform {
  Browser
  MacOS
  Windows
  Linux
  IOS
  Android
}

pub fn platform() -> Platform {
  case os.platform_string() {
    "macos" -> MacOS
    "windows" -> Windows
    "linux" -> Linux
    "ios" -> IOS
    "android" -> Android
    _ -> Browser
  }
}

pub fn is_desktop() -> Bool {
  case platform() {
    MacOS | Windows | Linux -> True
    _ -> False
  }
}

pub fn is_mobile() -> Bool {
  case platform() {
    IOS | Android -> True
    _ -> False
  }
}
