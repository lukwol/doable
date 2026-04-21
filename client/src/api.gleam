import app/platform.{Browser}
import browser
import error.{
  type ApiError, DecodeError, FetchError, InvalidUrl, UnexpectedStatus,
}
import gleam/bool
import gleam/dynamic/decode.{type Decoder}
import gleam/fetch.{type FetchBody, type FetchError}
import gleam/http.{Delete, Get, Patch, Post}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/javascript/promise.{type Promise}
import gleam/option.{None, Some}
import gleam/result
import tauri/commands
import tauri/http as tauri_http

pub fn get(path: String, decoder: Decoder(a)) -> Promise(Result(a, ApiError)) {
  use req <- with_json_request(path)
  req
  |> request.set_method(Get)
  |> execute(expect: 200, decoder:)
}

pub fn post(
  path: String,
  decoder: Decoder(a),
  json body: String,
) -> Promise(Result(a, ApiError)) {
  use req <- with_json_request(path)
  req
  |> request.set_method(Post)
  |> request.set_header("content-type", "application/json")
  |> request.set_body(body)
  |> execute(expect: 201, decoder:)
}

pub fn patch(
  path: String,
  decoder: Decoder(a),
  json body: String,
) -> Promise(Result(a, ApiError)) {
  use req <- with_json_request(path)
  req
  |> request.set_method(Patch)
  |> request.set_header("content-type", "application/json")
  |> request.set_body(body)
  |> execute(expect: 200, decoder:)
}

pub fn delete(path: String) -> Promise(Result(Nil, ApiError)) {
  use request <- with_json_request(path)
  request
  |> request.set_method(Delete)
  |> send
  |> promise.map(result.map_error(_, FetchError))
  |> promise.map_try(fn(response) {
    use <- bool.guard(
      response.status != 204,
      Error(UnexpectedStatus(response.status)),
    )
    Ok(Nil)
  })
}

fn api_base_url() -> Promise(String) {
  use tauri_is_dev <- promise.await(commands.tauri_is_dev())
  use tauri_dev_host <- promise.map(commands.tauri_dev_host())
  case platform.platform(), tauri_is_dev, tauri_dev_host {
    Browser, _, _ -> browser.window_location_origin()
    _, True, Some(host) -> "http://" <> host <> ":8000"
    _, True, None -> "http://localhost:8000"
    _, False, _ -> "https://your-domain.com"
  }
}

fn send(
  request: request.Request(String),
) -> Promise(Result(Response(FetchBody), FetchError)) {
  request
  |> fetch.to_fetch_request
  |> tauri_http.raw_send
  |> promise.try_await(fn(resp) {
    promise.resolve(Ok(fetch.from_fetch_response(resp)))
  })
}

fn with_json_request(
  path: String,
  callback: fn(Request(String)) -> Promise(Result(b, ApiError)),
) -> Promise(Result(b, ApiError)) {
  use base_url <- promise.await(api_base_url())
  let url = base_url <> path
  request.to(url)
  |> result.replace_error(InvalidUrl(url))
  |> result.map(request.set_header(_, "accept", "application/json"))
  |> promise.resolve
  |> promise.try_await(callback)
}

fn execute(
  req: Request(String),
  expect expect: Int,
  decoder decoder: Decoder(a),
) -> Promise(Result(a, ApiError)) {
  req
  |> send
  |> promise.try_await(fetch.read_json_body)
  |> promise.map(result.map_error(_, FetchError))
  |> promise.map_try(fn(response) {
    use <- bool.guard(
      response.status != expect,
      Error(UnexpectedStatus(response.status)),
    )
    response.body
    |> decode.run(decoder)
    |> result.map_error(DecodeError)
  })
}
