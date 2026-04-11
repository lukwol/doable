import gleam/option.{None}
import gleam/result
import gleam/uri.{type Uri}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import modem
import page/tasks
import route

pub type Page {
  TasksPage(tasks.Model)
}

pub type Msg {
  OnRouteChanged(route.Route)
  TasksPageSentMsg(tasks.Msg)
}

pub fn init(initial_uri: Result(Uri, Nil)) -> #(Page, Effect(Msg)) {
  initial_uri
  |> result.map(page_from_uri)
  |> result.unwrap(page_from_route(route.home_route))
}

pub fn on_url_change(uri: Uri) -> Msg {
  OnRouteChanged(route.from_uri(uri))
}

pub fn update(page: Page, msg: Msg) -> #(Page, Effect(Msg)) {
  case msg, page {
    OnRouteChanged(route), _ -> page_from_route(route)
    TasksPageSentMsg(page_msg), TasksPage(page_model) -> {
      let #(new_page_model, effect) = tasks.update(page_model, page_msg)
      #(TasksPage(new_page_model), effect.map(effect, TasksPageSentMsg))
    }
  }
}

pub fn view(page: Page) -> Element(Msg) {
  case page {
    TasksPage(page_model) ->
      tasks.view(page_model) |> element.map(TasksPageSentMsg)
  }
}

fn page_from_uri(uri: Uri) -> #(Page, Effect(Msg)) {
  let route = route.from_uri(uri)
  let #(page, effect) = page_from_route(route)
  let redirect = case uri.path_segments(uri.path) {
    [] -> modem.replace(route.to_path(route), None, None)
    _ -> effect.none()
  }
  #(page, effect.batch([effect, redirect]))
}

fn page_from_route(route: route.Route) -> #(Page, Effect(Msg)) {
  case route {
    route.Tasks -> {
      let #(page_model, effect) = tasks.init()
      #(TasksPage(page_model), effect.map(effect, TasksPageSentMsg))
    }
  }
}
