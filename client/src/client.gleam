import app/platform.{Android, Browser, IOS, Linux, MacOS, Windows}
import browser
import lustre
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import modem
import router
import tauri/menu

pub fn main() {
  case platform.platform() {
    MacOS | Windows | Linux -> browser.add_body_class("desktop")
    IOS | Android -> browser.add_body_class("mobile")
    Browser -> browser.add_body_class("browser")
  }
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

pub type Msg {
  RouterSentMsg(router.Msg)
  MenuSentEvent(String)
}

type Model {
  Model(page: router.Page)
}

fn init(_) -> #(Model, Effect(Msg)) {
  let #(page, router_effect) = router.init(modem.initial_uri())
  let effects = [
    modem.init(router.on_url_change) |> effect.map(RouterSentMsg),
    router_effect |> effect.map(RouterSentMsg),
  ]
  let effects = case platform.is_desktop() {
    True -> [menu.subscribe(MenuSentEvent), ..effects]
    False -> effects
  }
  #(Model(page:), effect.batch(effects))
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    RouterSentMsg(msg) -> {
      let #(page, effect) = router.update(model.page, msg)
      #(Model(page:), effect |> effect.map(RouterSentMsg))
    }
    MenuSentEvent("reload") -> {
      #(model, effect.from(fn(_) { browser.reload_page() }))
    }
    MenuSentEvent(_) -> #(model, effect.none())
  }
}

fn view(model: Model) -> Element(Msg) {
  router.view(model.page) |> element.map(RouterSentMsg)
}
