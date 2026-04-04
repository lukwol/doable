import context
import fixtures
import gleam/http
import gleam/int
import gleam/json
import router
import task
import task/repository
import test_context
import test_database
import wisp/simulate

pub fn update_task_test() {
  let ctx = test_context.get()
  use ctx <- test_database.with_rollback(ctx)

  let db_conn = context.db_conn(ctx)
  let assert Ok(created) =
    repository.create_task(db_conn, task.to_task_input(fixtures.task1))

  let updated_input = task.to_task_input(fixtures.task2)
  let body = task.task_input_to_json(updated_input)

  let response =
    simulate.request(http.Patch, "/api/tasks/" <> int.to_string(created.id))
    |> simulate.json_body(body)
    |> router.handle_request(ctx)

  assert response.status == 200
  let assert Ok(task) =
    json.parse(simulate.read_body(response), task.task_decoder())

  assert task.to_task_input(task) == updated_input
}

pub fn update_task_not_found_test() {
  let ctx = test_context.get()

  let body = task.task_input_to_json(task.to_task_input(fixtures.task1))

  let response =
    simulate.request(http.Patch, "/api/tasks/123456789")
    |> simulate.json_body(body)
    |> router.handle_request(ctx)

  assert response.status == 404
  assert simulate.read_body(response) == "Not found"
}

pub fn update_task_invalid_id_test() {
  let ctx = test_context.get()

  let body = task.task_input_to_json(task.to_task_input(fixtures.task1))

  let response =
    simulate.request(http.Patch, "/api/tasks/not-an-id")
    |> simulate.json_body(body)
    |> router.handle_request(ctx)

  assert response.status == 404
  assert simulate.read_body(response) == "Not found"
}

pub fn update_task_invalid_json_test() {
  let ctx = test_context.get()

  let response =
    simulate.request(http.Patch, "/api/tasks/1")
    |> simulate.json_body(json.object([#("foo", json.string("bar"))]))
    |> router.handle_request(ctx)

  assert response.status == 422
  assert simulate.read_body(response) == "Unprocessable content"
}

pub fn update_task_malformed_body_test() {
  let ctx = test_context.get()

  let response =
    simulate.request(http.Patch, "/api/tasks/1")
    |> simulate.string_body("{not valid json}")
    |> simulate.header("content-type", "application/json")
    |> router.handle_request(ctx)

  assert response.status == 400
  assert simulate.read_body(response) == "Bad request: Invalid JSON"
}

pub fn update_task_wrong_method_test() {
  let ctx = test_context.get()

  let response =
    simulate.request(http.Post, "/api/tasks/1")
    |> router.handle_request(ctx)

  assert response.status == 405
  assert simulate.read_body(response) == "Method not allowed"
}
