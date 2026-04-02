import context.{type Context}
import gleam/http.{Delete, Get, Patch, Post}
import task/route as task_routes
import web
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    ["api", "tasks", ..rest] -> handle_tasks(rest, req, ctx)
    _ -> wisp.not_found()
  }
}

fn handle_tasks(segments: List(String), req: Request, ctx: Context) -> Response {
  case segments, req.method {
    [], Get -> task_routes.list_tasks(ctx)
    [], Post -> task_routes.create_task(req, ctx)
    [], _ -> wisp.method_not_allowed([Get, Post])

    [id], Get -> task_routes.show_task(req, ctx, id)
    [id], Patch -> task_routes.update_task(req, ctx, id)
    [id], Delete -> task_routes.delete_task(req, ctx, id)
    [_], _ -> wisp.method_not_allowed([Get, Patch, Delete])
    _, _ -> wisp.not_found()
  }
}
