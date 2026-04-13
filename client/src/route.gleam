import gleam/uri.{type Uri}

pub const home_route = Tasks

pub type Route {
  Tasks
  NewTask
}

pub fn to_path(route: Route) -> String {
  case route {
    Tasks -> "/tasks"
    NewTask -> "/tasks/new"
  }
}

pub fn from_uri(uri: Uri) -> Route {
  case uri.path_segments(uri.path) {
    ["tasks"] -> Tasks
    ["tasks", "new"] -> NewTask
    _ -> home_route
  }
}
