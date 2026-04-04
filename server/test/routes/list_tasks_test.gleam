import context
import fixtures
import gleam/dynamic/decode
import gleam/http
import gleam/json
import gleam/list
import router
import task
import task/repository
import test_context
import test_database
import wisp/simulate

pub fn empty_list_tasks_test() {
  let ctx = test_context.get()

  let response =
    simulate.request(http.Get, "/api/tasks")
    |> router.handle_request(ctx)

  assert response.status == 200

  let body = simulate.read_body(response)
  let assert Ok(tasks) = json.parse(body, decode.list(task.task_decoder()))

  assert tasks == []
}

pub fn not_empty_list_tasks_test() {
  let ctx = test_context.get()
  use ctx <- test_database.with_rollback(ctx)

  let db_conn = context.db_conn(ctx)
  let inputs =
    [fixtures.task1, fixtures.task2]
    |> list.map(task.to_task_input)

  inputs
  |> list.each(fn(input) {
    let assert Ok(_) = repository.create_task(db_conn, input)
  })

  let response =
    simulate.request(http.Get, "/api/tasks")
    |> router.handle_request(ctx)

  assert response.status == 200

  let body = simulate.read_body(response)
  let assert Ok(tasks) = json.parse(body, decode.list(task.task_decoder()))

  assert list.map(tasks, task.to_task_input) == list.reverse(inputs)
}

pub fn list_tasks_wrong_method_test() {
  let ctx = test_context.get()

  let response =
    simulate.request(http.Delete, "/api/tasks")
    |> router.handle_request(ctx)

  // Expects 405 Method Not Allowed
  assert response.status == 405
  assert simulate.read_body(response) == "Method not allowed"
}
