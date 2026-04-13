import error.{type ApiError}
import gleam/javascript/promise
import gleam/list
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import route
import service/task_service
import task.{type Task}

pub type Model {
  Model(tasks: Result(List(Task), ApiError), loading: Bool)
}

pub type Msg {
  ApiReturnedTasks(Result(List(Task), ApiError))
}

pub fn init() -> #(Model, Effect(Msg)) {
  #(Model(tasks: Ok([]), loading: True), fetch_tasks())
}

pub fn update(_model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ApiReturnedTasks(Ok(tasks)) -> #(
      Model(tasks: Ok(tasks), loading: False),
      effect.none(),
    )
    ApiReturnedTasks(Error(err)) -> #(
      Model(tasks: Error(err), loading: False),
      effect.none(),
    )
  }
}

pub fn view(model: Model) -> Element(Msg) {
  html.div([], [
    html.h1([], [element.text("Tasks")]),
    html.a([attribute.href(route.to_path(route.NewTask))], [
      element.text("New Task"),
    ]),
    case model.tasks {
      Error(err) -> html.p([], [element.text(error.message(err))])
      Ok([]) if model.loading -> html.p([], [element.text("Loading...")])
      Ok([]) -> html.p([], [element.text("No tasks yet")])
      Ok(tasks) -> html.ul([], list.map(tasks, view_task))
    },
  ])
}

fn fetch_tasks() -> Effect(Msg) {
  use dispatch <- effect.from
  task_service.fetch_tasks()
  |> promise.map(ApiReturnedTasks)
  |> promise.tap(dispatch)
  Nil
}

fn view_task(task: Task) -> Element(Msg) {
  html.li([], [
    html.input([
      attribute.type_("checkbox"),
      attribute.checked(task.completed),
      attribute.disabled(True),
    ]),
    element.text(task.name <> " — " <> task.description),
  ])
}
