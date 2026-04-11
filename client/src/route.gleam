import gleam/uri.{type Uri}

pub const home_route = Tasks

pub type Route {
  Tasks
}

pub fn to_path(route: Route) -> String {
  case route {
    Tasks -> "/tasks"
  }
}

pub fn from_uri(uri: Uri) -> Route {
  case uri.path_segments(uri.path) {
    ["tasks"] -> Tasks
    _ -> home_route
  }
}
