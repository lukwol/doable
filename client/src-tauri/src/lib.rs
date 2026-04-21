#[cfg(desktop)]
use tauri::{
    AppHandle, Emitter,
    menu::{Menu, MenuEvent, MenuItem, Submenu},
};
use tauri::{Builder, Runtime};

trait BuilderExt<R: Runtime> {
    fn setup_platform(self) -> Self;
}

#[cfg(desktop)]
impl<R: Runtime> BuilderExt<R> for Builder<R> {
    fn setup_platform(self) -> Self {
        self.setup(|app| {
            let reload_item =
                MenuItem::with_id(app.handle(), "reload", "Reload", true, Some("CmdOrCtrl+R"))?;
            let view_submenu = Submenu::with_items(app.handle(), "View", true, &[&reload_item])?;
            let menu = Menu::default(app.handle())?;
            menu.append(&view_submenu)?;
            app.set_menu(menu)?;
            Ok(())
        })
        .on_menu_event(|app: &AppHandle<R>, event: MenuEvent| {
            app.emit("menu-event", event.id().as_ref()).ok();
        })
    }
}

#[cfg(mobile)]
impl<R: Runtime> BuilderExt<R> for Builder<R> {
    fn setup_platform(self) -> Self {
        self.setup(|app| {
            app.handle().plugin(tauri_plugin_haptics::init())?;
            Ok(())
        })
    }
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_http::init())
        .plugin(tauri_plugin_os::init())
        .setup_platform()
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
