import tauri/os

pub type Platform {
  Browser
  MacOS
  Windows
  Linux
}

pub fn platform() -> Platform {
  case os.platform_string() {
    "macos" -> MacOS
    "windows" -> Windows
    "linux" -> Linux
    _ -> Browser
  }
}

pub fn is_desktop() -> Bool {
  case platform() {
    MacOS | Windows | Linux -> True
    _ -> False
  }
}
