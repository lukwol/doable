import gleam/option.{type Option, None, Some}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub type Msg {
  UserUpdatedName(String)
  UserUpdatedDescription(String)
  UserUpdatedCompleted(Bool)
}

pub fn view(
  name: String,
  description: String,
  completed: Option(Bool),
) -> Element(Msg) {
  html.div([attribute.class("space-y-4")], [
    html.div([attribute.class("form-control")], [
      html.label([attribute.class("label")], [element.text("Name")]),
      html.input([
        attribute.type_("text"),
        attribute.placeholder("Task name"),
        attribute.value(name),
        attribute.class("w-full input input-bordered"),
        event.on_input(UserUpdatedName),
      ]),
    ]),
    html.div([attribute.class("form-control")], [
      html.label([attribute.class("label")], [element.text("Description")]),
      html.textarea(
        [
          attribute.placeholder("Optional description"),
          attribute.class("w-full textarea textarea-bordered"),
          event.on_input(UserUpdatedDescription),
        ],
        description,
      ),
    ]),
    case completed {
      None -> element.none()
      Some(value) ->
        html.label(
          [attribute.class("gap-3 justify-start cursor-pointer label")],
          [
            html.input([
              attribute.type_("checkbox"),
              attribute.checked(value),
              attribute.class("checkbox"),
              event.on_check(UserUpdatedCompleted),
            ]),
            element.text("Completed"),
          ],
        )
    },
  ])
}
