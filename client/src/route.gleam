import gleam/int
import gleam/result
import gleam/uri.{type Uri}

pub const home_route = Tasks

pub type Route {
  Tasks
  NewTask
  EditTask(Int)
}

pub fn to_path(route: Route) -> String {
  case route {
    Tasks -> "/tasks"
    NewTask -> "/tasks/new"
    EditTask(id) -> "/tasks/" <> int.to_string(id) <> "/edit"
  }
}

pub fn from_uri(uri: Uri) -> Route {
  case uri.path_segments(uri.path) {
    ["tasks"] -> Tasks
    ["tasks", "new"] -> NewTask
    ["tasks", id, "edit"] ->
      int.parse(id)
      |> result.map(EditTask)
      |> result.unwrap(home_route)
    _ -> home_route
  }
}
