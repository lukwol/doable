import lustre/effect.{type Effect}

@external(javascript, "./menu_ffi.js", "listen_menu_events")
fn listen_menu_events(dispatch: fn(String) -> Nil) -> Nil

pub fn subscribe(to_msg: fn(String) -> msg) -> Effect(msg) {
  use dispatch <- effect.from
  use id <- listen_menu_events
  to_msg(id) |> dispatch
}
