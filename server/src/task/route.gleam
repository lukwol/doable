import context.{type Context}
import gleam/json
import task
import task/repository
import web
import wisp.{type Request, type Response}

pub fn list_tasks(ctx: Context) -> Response {
  let db = context.db_conn(ctx)
  use tasks <- web.db_execute(repository.all_tasks(db))

  tasks
  |> json.array(task.task_to_json)
  |> json.to_string
  |> wisp.json_body(wisp.ok(), _)
}

pub fn create_task(req: Request, ctx: Context) -> Response {
  let db = context.db_conn(ctx)
  use json <- wisp.require_json(req)
  use task_input <- web.decode_body(json, task.task_input_decoder())
  use task <- web.db_execute(repository.create_task(db, task_input))

  task
  |> task.task_to_json
  |> json.to_string
  |> wisp.json_body(wisp.created(), _)
}

pub fn show_task(_req: Request, ctx: Context, id: String) -> Response {
  let db = context.db_conn(ctx)
  use id <- web.parse_id(id)
  use task <- web.db_execute(repository.get_task(db, id))

  task
  |> task.task_to_json
  |> json.to_string
  |> wisp.json_body(wisp.ok(), _)
}

pub fn update_task(req: Request, ctx: Context, id: String) -> Response {
  let db = context.db_conn(ctx)
  use id <- web.parse_id(id)
  use json <- wisp.require_json(req)
  use task_input <- web.decode_body(json, task.task_input_decoder())
  let task = task_input |> task.to_task(id)
  use task <- web.db_execute(repository.update_task(db, task))

  task
  |> task.task_to_json
  |> json.to_string
  |> wisp.json_body(wisp.ok(), _)
}

pub fn delete_task(_req: Request, ctx: Context, id: String) -> Response {
  let db = context.db_conn(ctx)
  use id <- web.parse_id(id)
  use _ <- web.db_execute(repository.delete_task(db, id))

  wisp.no_content()
}
