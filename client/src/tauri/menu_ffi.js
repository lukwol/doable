import { listen } from "@tauri-apps/api/event";

export function listen_menu_events(dispatch) {
  listen("menu-event", (event) => {
    dispatch(event.payload);
  });
}
