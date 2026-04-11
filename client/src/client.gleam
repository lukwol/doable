import lustre
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import modem
import router

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

type Model {
  Model(page: router.Page)
}

fn init(_) -> #(Model, Effect(router.Msg)) {
  let #(page, router_effect) = router.init(modem.initial_uri())
  #(
    Model(page:),
    effect.batch([modem.init(router.on_url_change), router_effect]),
  )
}

fn update(model: Model, msg: router.Msg) -> #(Model, Effect(router.Msg)) {
  let #(page, effect) = router.update(model.page, msg)
  #(Model(page:), effect)
}

fn view(model: Model) -> Element(router.Msg) {
  router.view(model.page)
}
