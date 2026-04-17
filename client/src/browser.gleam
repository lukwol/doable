@external(javascript, "./browser_ffi.js", "window_location_origin")
pub fn window_location_origin() -> String

@external(javascript, "./browser_ffi.js", "history_back")
pub fn history_back() -> Nil

@external(javascript, "./browser_ffi.js", "reload_page")
pub fn reload_page() -> Nil

@external(javascript, "./browser_ffi.js", "add_body_class")
pub fn add_body_class(class_name: String) -> Nil
