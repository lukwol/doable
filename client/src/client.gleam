import lustre
import lustre/element.{text}
import lustre/element/html.{button, div, input, p}
import lustre/event.{on_click, on_input}

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Model {
  Model(name: String, greeting: String)
}

fn init(_flags) {
  Model(name: "", greeting: "")
}

type Msg {
  UserUpdatedName(String)
  UserClickedGreet
}

fn update(model: Model, msg: Msg) {
  case msg {
    UserUpdatedName(name) -> Model(..model, name: name)
    UserClickedGreet -> Model(..model, greeting: "Hello " <> model.name <> "!")
  }
}

fn view(model: Model) {
  div([], [
    input([on_input(UserUpdatedName)]),
    button([on_click(UserClickedGreet)], [text("Greet")]),
    p([], [text(model.greeting)]),
  ])
}
