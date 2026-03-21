import wisp.{type Request, type Response}

pub fn list_tasks() -> Response {
  wisp.ok()
  |> wisp.json_body("[]")
}

pub fn create_task(_req: Request) -> Response {
  wisp.created()
  |> wisp.json_body("{}")
}

pub fn show_task(_req: Request, _id: String) -> Response {
  wisp.ok()
  |> wisp.json_body("{}")
}

pub fn update_task(_req: Request, _id: String) -> Response {
  wisp.ok()
  |> wisp.json_body("{}")
}

pub fn delete_task(_req: Request, _id: String) -> Response {
  wisp.no_content()
}
