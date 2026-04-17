use tauri::{
    AppHandle, Emitter,
    menu::{Menu, MenuEvent, MenuItem, Submenu},
};

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_os::init())
        .setup(|app| {
            if cfg!(debug_assertions) {
                app.handle().plugin(
                    tauri_plugin_log::Builder::default()
                        .level(log::LevelFilter::Info)
                        .build(),
                )?;
            }
            let reload_item =
                MenuItem::with_id(app.handle(), "reload", "Reload", true, Some("CmdOrCtrl+R"))?;
            let view_submenu = Submenu::with_items(app.handle(), "View", true, &[&reload_item])?;
            let menu = Menu::default(app.handle())?;
            menu.append(&view_submenu)?;
            app.set_menu(menu)?;
            Ok(())
        })
        .on_menu_event(|app: &AppHandle, event: MenuEvent| {
            app.emit("menu-event", event.id().as_ref()).ok();
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
