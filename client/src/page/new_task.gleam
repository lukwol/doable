import browser
import component/task_form.{
  UserUpdatedCompleted, UserUpdatedDescription, UserUpdatedName,
}
import error.{type ApiError}
import gleam/javascript/promise
import gleam/option.{type Option, None, Some}
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import modem
import route
import service/task_service
import task.{type Task, TaskInput}

pub type Model {
  Model(
    name: String,
    description: String,
    submitting: Bool,
    error: Option(String),
  )
}

pub type Msg {
  FormMsg(task_form.Msg)
  UserSubmittedForm
  UserClickedBack
  ApiCreatedTask(Result(Task, ApiError))
}

pub fn init() -> #(Model, Effect(Msg)) {
  #(
    Model(name: "", description: "", submitting: False, error: None),
    effect.none(),
  )
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    FormMsg(UserUpdatedName(name)) -> #(Model(..model, name:), effect.none())
    FormMsg(UserUpdatedDescription(description)) -> #(
      Model(..model, description:),
      effect.none(),
    )
    FormMsg(UserUpdatedCompleted(_)) -> #(model, effect.none())
    UserSubmittedForm ->
      case model.name {
        "" -> #(Model(..model, error: Some("Name is required")), effect.none())
        _ -> #(
          Model(..model, submitting: True, error: None),
          post_task(model.name, model.description),
        )
      }
    UserClickedBack -> #(model, effect.from(fn(_) { browser.history_back() }))
    ApiCreatedTask(Ok(_)) -> #(
      model,
      modem.push(route.to_path(route.Tasks), None, None),
    )
    ApiCreatedTask(Error(err)) -> #(
      Model(..model, submitting: False, error: Some(error.message(err))),
      effect.none(),
    )
  }
}

pub fn view(model: Model) -> Element(Msg) {
  html.div([], [
    html.h1([], [element.text("New Task")]),
    case model.error {
      None -> element.none()
      Some(err) -> html.p([], [element.text(err)])
    },
    task_form.view(model.name, model.description, None)
      |> element.map(FormMsg),
    html.div([], [
      html.button(
        [
          attribute.disabled(model.submitting),
          event.on_click(UserSubmittedForm),
        ],
        [
          element.text(case model.submitting {
            True -> "Saving..."
            False -> "Save"
          }),
        ],
      ),
      html.button([event.on_click(UserClickedBack)], [element.text("Back")]),
    ]),
  ])
}

fn post_task(name: String, description: String) -> Effect(Msg) {
  use dispatch <- effect.from
  TaskInput(name:, description:, completed: False)
  |> task_service.post_task
  |> promise.map(ApiCreatedTask)
  |> promise.tap(dispatch)
  Nil
}
