import fixtures
import gleam/http
import gleam/json
import router
import task
import test_context
import test_database
import wisp/simulate

pub fn create_task_with_completed_test() {
  let ctx = test_context.get()
  use ctx <- test_database.with_rollback(ctx)

  let body =
    fixtures.task1
    |> task.to_task_input
    |> task.task_input_to_json

  let response =
    simulate.request(http.Post, "/api/tasks")
    |> simulate.json_body(body)
    |> router.handle_request(ctx)

  // Expects 201 Created
  assert response.status == 201
  let body = simulate.read_body(response)
  let assert Ok(task) = json.parse(body, task.task_decoder())

  assert task.to_task_input(task) == task.to_task_input(fixtures.task1)
}

pub fn create_task_without_completed_test() {
  let ctx = test_context.get()
  use ctx <- test_database.with_rollback(ctx)

  // Omit completed field — should default to False
  let body =
    json.object([
      #("name", json.string("Paint the fence")),
      #("description", json.string("Two coats of white paint")),
    ])

  let response =
    simulate.request(http.Post, "/api/tasks")
    |> simulate.json_body(body)
    |> router.handle_request(ctx)

  assert response.status == 201
  let body = simulate.read_body(response)
  let assert Ok(task) = json.parse(body, task.task_decoder())

  assert task.name == "Paint the fence"
  assert task.description == "Two coats of white paint"
  assert task.completed == False
}

pub fn create_task_with_invalid_json_test() {
  let ctx = test_context.get()

  let body = json.object([#("foo", json.string("bar"))])

  let response =
    simulate.request(http.Post, "/api/tasks")
    |> simulate.json_body(body)
    |> router.handle_request(ctx)

  // Expects 422 Unprocessable Content
  assert response.status == 422
  assert simulate.read_body(response) == "Unprocessable content"
}

pub fn create_task_with_malformed_body_test() {
  let ctx = test_context.get()

  let response =
    simulate.request(http.Post, "/api/tasks")
    |> simulate.string_body("{not valid json}")
    |> simulate.header("content-type", "application/json")
    |> router.handle_request(ctx)

  // Expects 400 Bad Request
  assert response.status == 400
  assert simulate.read_body(response) == "Bad request: Invalid JSON"
}
