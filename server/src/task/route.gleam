import context.{type Context}
import wisp.{type Request, type Response}

pub fn list_tasks(_ctx: Context) -> Response {
  wisp.ok()
  |> wisp.json_body("[]")
}

pub fn create_task(_req: Request, _ctx: Context) -> Response {
  wisp.created()
  |> wisp.json_body("{}")
}

pub fn show_task(_req: Request, _ctx: Context, _id: String) -> Response {
  wisp.ok()
  |> wisp.json_body("{}")
}

pub fn update_task(_req: Request, _ctx: Context, _id: String) -> Response {
  wisp.ok()
  |> wisp.json_body("{}")
}

pub fn delete_task(_req: Request, _ctx: Context, _id: String) -> Response {
  wisp.no_content()
}
