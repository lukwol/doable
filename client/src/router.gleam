import gleam/option.{None}
import gleam/result
import gleam/uri.{type Uri}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import modem
import page/edit_task
import page/new_task
import page/tasks
import route

pub type Page {
  TasksPage(tasks.Model)
  NewTaskPage(new_task.Model)
  EditTaskPage(edit_task.Model)
}

pub type Msg {
  OnRouteChanged(route.Route)
  TasksPageSentMsg(tasks.Msg)
  NewTaskPageSentMsg(new_task.Msg)
  EditTaskPageSentMsg(edit_task.Msg)
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
    NewTaskPageSentMsg(page_msg), NewTaskPage(page_model) -> {
      let #(new_page_model, effect) = new_task.update(page_model, page_msg)
      #(NewTaskPage(new_page_model), effect.map(effect, NewTaskPageSentMsg))
    }
    EditTaskPageSentMsg(page_msg), EditTaskPage(page_model) -> {
      let #(new_page_model, effect) = edit_task.update(page_model, page_msg)
      #(EditTaskPage(new_page_model), effect.map(effect, EditTaskPageSentMsg))
    }
    _, _ -> panic as "mismatched msg and page"
  }
}

pub fn view(page: Page) -> Element(Msg) {
  case page {
    TasksPage(page_model) ->
      tasks.view(page_model) |> element.map(TasksPageSentMsg)
    NewTaskPage(page_model) ->
      new_task.view(page_model) |> element.map(NewTaskPageSentMsg)
    EditTaskPage(page_model) ->
      edit_task.view(page_model) |> element.map(EditTaskPageSentMsg)
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
    route.NewTask -> {
      let #(page_model, effect) = new_task.init()
      #(NewTaskPage(page_model), effect.map(effect, NewTaskPageSentMsg))
    }
    route.EditTask(id) -> {
      let #(page_model, effect) = edit_task.init(id)
      #(EditTaskPage(page_model), effect.map(effect, EditTaskPageSentMsg))
    }
  }
}
