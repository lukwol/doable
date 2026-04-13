import api
import error.{type ApiError}
import gleam/dynamic/decode
import gleam/javascript/promise.{type Promise}
import gleam/json
import task.{type Task, type TaskInput}

pub fn fetch_tasks() -> Promise(Result(List(Task), ApiError)) {
  "/api/tasks"
  |> api.get(decode.list(task.task_decoder()))
}

pub fn post_task(input: TaskInput) -> Promise(Result(Task, ApiError)) {
  let body =
    input
    |> task.task_input_to_json
    |> json.to_string

  "/api/tasks"
  |> api.post(task.task_decoder(), json: body)
}
