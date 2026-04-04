import context
import fixtures
import gleam/http
import gleam/int
import router
import task
import task/repository
import test_context
import test_database
import wisp/simulate

pub fn delete_task_test() {
  let ctx = test_context.get()
  use ctx <- test_database.with_rollback(ctx)

  let db_conn = context.db_conn(ctx)
  let assert Ok(created) =
    repository.create_task(db_conn, task.to_task_input(fixtures.task1))

  let response =
    simulate.request(http.Delete, "/api/tasks/" <> int.to_string(created.id))
    |> router.handle_request(ctx)

  assert response.status == 204
}

pub fn delete_task_not_found_test() {
  let ctx = test_context.get()

  let response =
    simulate.request(http.Delete, "/api/tasks/123456789")
    |> router.handle_request(ctx)

  assert response.status == 404
  assert simulate.read_body(response) == "Not found"
}

pub fn delete_task_invalid_id_test() {
  let ctx = test_context.get()

  let response =
    simulate.request(http.Delete, "/api/tasks/not-an-id")
    |> router.handle_request(ctx)

  assert response.status == 404
  assert simulate.read_body(response) == "Not found"
}

pub fn delete_task_wrong_method_test() {
  let ctx = test_context.get()

  let response =
    simulate.request(http.Post, "/api/tasks/1")
    |> router.handle_request(ctx)

  assert response.status == 405
  assert simulate.read_body(response) == "Method not allowed"
}
