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
import task.{type Task, Task}

pub type Model {
  Model(task: Task, loading: Bool, submitting: Bool, error: Option(String))
}

pub type Msg {
  FormMsg(task_form.Msg)
  UserSubmittedForm
  UserClickedDelete
  UserClickedBack
  ApiReturnedTask(Result(Task, ApiError))
  ApiUpdatedTask(Result(Task, ApiError))
  ApiDeletedTask(Result(Nil, ApiError))
}

pub fn init(task_id: Int) -> #(Model, Effect(Msg)) {
  #(
    Model(
      task: Task(id: task_id, name: "", description: "", completed: False),
      loading: True,
      submitting: False,
      error: None,
    ),
    fetch_task(task_id),
  )
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    FormMsg(UserUpdatedName(name)) -> #(
      Model(..model, task: Task(..model.task, name:)),
      effect.none(),
    )
    FormMsg(UserUpdatedDescription(description)) -> #(
      Model(..model, task: Task(..model.task, description:)),
      effect.none(),
    )
    FormMsg(UserUpdatedCompleted(completed)) -> #(
      Model(..model, task: Task(..model.task, completed:)),
      effect.none(),
    )
    UserSubmittedForm ->
      case model.task.name {
        "" -> #(Model(..model, error: Some("Name is required")), effect.none())
        _ -> #(
          Model(..model, submitting: True, error: None),
          patch_task(model.task),
        )
      }
    UserClickedDelete -> #(
      Model(..model, submitting: True),
      delete_task(model.task.id),
    )
    UserClickedBack -> #(model, effect.from(fn(_) { browser.history_back() }))
    ApiReturnedTask(Ok(task)) -> #(
      Model(..model, task:, loading: False),
      effect.none(),
    )
    ApiReturnedTask(Error(err)) -> #(
      Model(..model, loading: False, error: Some(error.message(err))),
      effect.none(),
    )
    ApiUpdatedTask(Ok(_)) -> #(
      model,
      modem.push(route.to_path(route.Tasks), None, None),
    )
    ApiUpdatedTask(Error(err)) -> #(
      Model(..model, submitting: False, error: Some(error.message(err))),
      effect.none(),
    )
    ApiDeletedTask(Ok(_)) -> #(
      model,
      modem.push(route.to_path(route.Tasks), None, None),
    )
    ApiDeletedTask(Error(err)) -> #(
      Model(..model, submitting: False, error: Some(error.message(err))),
      effect.none(),
    )
  }
}

pub fn view(model: Model) -> Element(Msg) {
  case model.loading {
    True ->
      html.div(
        [
          attribute.class(
            "min-h-screen bg-base-200 flex items-center justify-center",
          ),
        ],
        [
          html.span([attribute.class("loading loading-spinner loading-lg")], []),
        ],
      )
    False ->
      html.div([attribute.class("min-h-screen bg-base-200")], [
        html.div([attribute.class("container p-4 mx-auto max-w-2xl")], [
          html.div([attribute.class("flex gap-2 items-center mb-6")], [
            html.button(
              [
                attribute.class("btn btn-ghost btn-sm btn-circle"),
                event.on_click(UserClickedBack),
              ],
              [
                html.span(
                  [attribute.class("icon-[heroicons--arrow-left] size-5")],
                  [],
                ),
              ],
            ),
            html.h1([attribute.class("text-2xl font-bold")], [
              element.text("Edit Task"),
            ]),
          ]),
          html.div([attribute.class("shadow card bg-base-100")], [
            html.div([attribute.class("card-body")], [
              case model.error {
                None -> element.none()
                Some(err) ->
                  html.div([attribute.class("mb-4 alert alert-error")], [
                    element.text(err),
                  ])
              },
              task_form.view(
                model.task.name,
                model.task.description,
                Some(model.task.completed),
              )
                |> element.map(FormMsg),
              html.div([attribute.class("flex gap-2 mt-6")], [
                html.button(
                  [
                    attribute.disabled(model.submitting),
                    attribute.class("btn btn-primary"),
                    event.on_click(UserSubmittedForm),
                  ],
                  [
                    case model.submitting {
                      True ->
                        html.span(
                          [
                            attribute.class(
                              "loading loading-spinner loading-sm",
                            ),
                          ],
                          [],
                        )
                      False ->
                        html.span(
                          [
                            attribute.class(
                              "icon-[heroicons--document-check] size-5",
                            ),
                          ],
                          [],
                        )
                    },
                    element.text(case model.submitting {
                      True -> "Saving..."
                      False -> "Save"
                    }),
                  ],
                ),
                html.button(
                  [
                    attribute.disabled(model.submitting),
                    attribute.class("btn btn-error"),
                    event.on_click(UserClickedDelete),
                  ],
                  [
                    html.span(
                      [attribute.class("icon-[heroicons--trash] size-5")],
                      [],
                    ),
                    element.text("Delete"),
                  ],
                ),
              ]),
            ]),
          ]),
        ]),
      ])
  }
}

fn fetch_task(task_id: Int) -> Effect(Msg) {
  use dispatch <- effect.from
  task_service.fetch_task(task_id)
  |> promise.map(ApiReturnedTask)
  |> promise.tap(dispatch)
  Nil
}

fn patch_task(task: Task) -> Effect(Msg) {
  use dispatch <- effect.from
  task_service.patch_task(task)
  |> promise.map(ApiUpdatedTask)
  |> promise.tap(dispatch)
  Nil
}

fn delete_task(task_id: Int) -> Effect(Msg) {
  use dispatch <- effect.from
  task_service.delete_task(task_id)
  |> promise.map(ApiDeletedTask)
  |> promise.tap(dispatch)
  Nil
}
