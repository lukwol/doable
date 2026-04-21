import gleam/javascript/promise.{type Promise}
import gleam/option.{type Option}

@external(javascript, "./commands_ffi.js", "tauri_is_dev")
pub fn tauri_is_dev() -> Promise(Bool)

@external(javascript, "./commands_ffi.js", "tauri_dev_host")
pub fn tauri_dev_host() -> Promise(Option(String))
