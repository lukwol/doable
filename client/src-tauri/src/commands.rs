#[tauri::command]
pub fn is_dev() -> bool {
    tauri::is_dev()
}

#[tauri::command]
pub fn tauri_dev_host() -> Option<String> {
    option_env!("TAURI_DEV_HOST").map(str::to_string)
}
