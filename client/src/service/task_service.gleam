import api
import error.{type ApiError}
import gleam/dynamic/decode
import gleam/int
import gleam/javascript/promise.{type Promise}
import gleam/json
import task.{type Task, type TaskInput}

pub fn fetch_tasks() -> Promise(Result(List(Task), ApiError)) {
  "/api/tasks"
  |> api.get(decode.list(task.task_decoder()))
}

pub fn fetch_task(task_id: Int) -> Promise(Result(Task, ApiError)) {
  let path = "/api/tasks/" <> int.to_string(task_id)
  path
  |> api.get(task.task_decoder())
}

pub fn post_task(input: TaskInput) -> Promise(Result(Task, ApiError)) {
  let body =
    input
    |> task.task_input_to_json
    |> json.to_string

  "/api/tasks"
  |> api.post(task.task_decoder(), json: body)
}

pub fn patch_task(task: Task) -> Promise(Result(Task, ApiError)) {
  let body =
    task
    |> task.to_task_input
    |> task.task_input_to_json
    |> json.to_string

  let path = "/api/tasks/" <> int.to_string(task.id)
  path
  |> api.patch(task.task_decoder(), json: body)
}

pub fn delete_task(task_id: Int) -> Promise(Result(Nil, ApiError)) {
  let path = "/api/tasks/" <> int.to_string(task_id)
  path
  |> api.delete
}
