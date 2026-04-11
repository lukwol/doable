import api
import error.{type ApiError}
import gleam/dynamic/decode
import gleam/javascript/promise.{type Promise}
import task.{type Task}

pub fn fetch_tasks() -> Promise(Result(List(Task), ApiError)) {
  "/api/tasks"
  |> api.get(decode.list(task.task_decoder()))
}
