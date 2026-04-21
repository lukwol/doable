import app/platform
import component/pull_refresh.{type PullState, Idle, Pulling, RefreshTriggered}
import error.{type ApiError}
import gleam/float
import gleam/javascript/promise
import gleam/list
import gleam/result
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import route
import service/task_service
import task.{type Task, Task}
import tauri/haptics

pub type Model {
  Model(
    tasks: Result(List(Task), ApiError),
    loading: Bool,
    pull_state: PullState,
  )
}

pub type Msg {
  ApiReturnedTasks(Result(List(Task), ApiError))
  UserToggledTask(Task, Bool)
  ApiUpdatedTask(Result(Task, ApiError))
  UserStartedTouch(Float)
  UserMovedTouch(Float)
  UserEndedTouch
}

pub fn init() -> #(Model, Effect(Msg)) {
  #(Model(tasks: Ok([]), loading: True, pull_state: Idle), fetch_tasks())
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ApiReturnedTasks(Ok(tasks)) -> #(
      Model(..model, tasks: Ok(tasks), loading: False),
      effect.none(),
    )
    ApiReturnedTasks(Error(err)) -> #(
      Model(..model, tasks: Error(err), loading: False),
      effect.none(),
    )
    UserToggledTask(task, completed) -> #(model, toggle_task(task, completed))
    ApiUpdatedTask(Ok(updated)) -> #(
      Model(
        ..model,
        tasks: result.map(
          model.tasks,
          list.map(_, fn(t) {
            case t.id == updated.id {
              True -> updated
              False -> t
            }
          }),
        ),
      ),
      effect.none(),
    )
    ApiUpdatedTask(Error(_)) -> #(model, effect.none())
    UserStartedTouch(y) -> #(
      Model(..model, pull_state: Pulling(start_y: y, offset: 0.0)),
      effect.none(),
    )
    UserMovedTouch(y) ->
      case model.pull_state {
        Idle | RefreshTriggered -> #(model, effect.none())
        Pulling(start_y:, offset: prev_offset) -> {
          let offset =
            float.max(0.0, y -. start_y)
            |> float.min(pull_refresh.threshold, _)
          let crossed =
            prev_offset <. pull_refresh.threshold
            && offset >=. pull_refresh.threshold
          let haptic = case crossed {
            True -> haptics.impact_feedback(haptics.Light)
            False -> effect.none()
          }
          #(Model(..model, pull_state: Pulling(start_y:, offset:)), haptic)
        }
      }
    UserEndedTouch ->
      case pull_refresh.release(model.pull_state) {
        RefreshTriggered -> #(
          Model(..model, loading: True, pull_state: Idle),
          fetch_tasks(),
        )
        _ -> #(Model(..model, pull_state: Idle), effect.none())
      }
  }
}

pub fn view(model: Model) -> Element(Msg) {
  case platform.is_mobile() {
    True -> view_mobile(model)
    False -> view_desktop(model)
  }
}

fn view_mobile(model: Model) -> Element(Msg) {
  html.div(
    [
      attribute.class("min-h-screen bg-base-200"),
      pull_refresh.on_touch_start(UserStartedTouch),
      pull_refresh.on_touch_move(UserMovedTouch),
      pull_refresh.on_touch_end(UserEndedTouch),
    ],
    [
      view_content(model, loading_placeholder: element.none()),
      pull_refresh.indicator(model.loading, model.pull_state),
    ],
  )
}

fn view_desktop(model: Model) -> Element(Msg) {
  html.div([attribute.class("min-h-screen bg-base-200")], [
    view_content(
      model,
      loading_placeholder: html.div(
        [attribute.class("flex justify-center p-8")],
        [
          html.span([attribute.class("loading loading-spinner loading-lg")], []),
        ],
      ),
    ),
  ])
}

fn view_content(
  model: Model,
  loading_placeholder loading_placeholder: Element(Msg),
) -> Element(Msg) {
  html.div([attribute.class("container p-4 mx-auto max-w-2xl")], [
    html.div([attribute.class("flex justify-between items-center mb-6")], [
      html.h1([attribute.class("text-3xl font-bold")], [
        element.text("Tasks"),
      ]),
      html.a(
        [
          attribute.href(route.to_path(route.NewTask)),
          attribute.class("btn btn-primary"),
        ],
        [
          html.span([attribute.class("icon-[heroicons--plus] size-5")], []),
          element.text("New Task"),
        ],
      ),
    ]),
    case model.tasks {
      Error(err) ->
        html.div([attribute.class("alert alert-error")], [
          element.text(error.message(err)),
        ])
      Ok([]) if model.loading -> loading_placeholder
      Ok([]) ->
        html.div([attribute.class("shadow card bg-base-100")], [
          html.div([attribute.class("items-center text-center card-body")], [
            html.p([attribute.class("text-base-content/60")], [
              element.text("No tasks yet"),
            ]),
          ]),
        ])
      Ok(tasks) ->
        html.ul([attribute.class("space-y-2")], list.map(tasks, view_task))
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

fn toggle_task(task: Task, completed: Bool) -> Effect(Msg) {
  use dispatch <- effect.from
  task_service.patch_task(Task(..task, completed:))
  |> promise.map(ApiUpdatedTask)
  |> promise.tap(dispatch)
  Nil
}

fn view_task(task: Task) -> Element(Msg) {
  html.li(
    [
      attribute.class(
        "card bg-base-100 shadow hover:shadow-md transition-shadow",
      ),
    ],
    [
      html.div([attribute.class("flex-row gap-3 items-center p-4 card-body")], [
        html.input([
          attribute.type_("checkbox"),
          attribute.checked(task.completed),
          attribute.class("checkbox checkbox-primary"),
          event.on_check(fn(checked) { UserToggledTask(task, checked) }),
        ]),
        html.a(
          [
            attribute.href(route.to_path(route.EditTask(task.id))),
            attribute.class("flex flex-1 gap-3 items-center min-w-0"),
          ],
          [
            html.div([attribute.class("flex-1 min-w-0")], [
              html.p(
                [
                  attribute.class(case task.completed {
                    True -> "font-medium line-through text-base-content/50"
                    False -> "font-medium"
                  }),
                ],
                [element.text(task.name)],
              ),
              case task.description {
                "" -> element.none()
                desc ->
                  html.p(
                    [attribute.class("text-sm text-base-content/60 truncate")],
                    [element.text(desc)],
                  )
              },
            ]),
            html.span(
              [
                attribute.class(
                  "icon-[heroicons--chevron-right] text-base-content/40 text-xl",
                ),
              ],
              [],
            ),
          ],
        ),
      ]),
    ],
  )
}
