import error.{type DatabaseError, RecordNotFound}
import gleam/dynamic/decode.{type Decoder}
import gleam/int
import wisp.{type Request, type Response}

pub fn middleware(
  req: Request,
  handle_request: fn(Request) -> Response,
) -> Response {
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  handle_request(req)
}

pub fn parse_id(id: String, next: fn(Int) -> Response) -> Response {
  case int.parse(id) {
    Ok(value) -> next(value)
    Error(_) -> wisp.not_found()
  }
}

pub fn decode_body(
  json: decode.Dynamic,
  decoder: Decoder(a),
  next: fn(a) -> Response,
) -> Response {
  case decode.run(json, decoder) {
    Ok(value) -> next(value)
    Error(_) -> wisp.unprocessable_content()
  }
}

pub fn db_execute(
  result: Result(a, DatabaseError),
  next: fn(a) -> Response,
) -> Response {
  case result {
    Ok(value) -> next(value)
    Error(RecordNotFound) -> wisp.not_found()
    Error(_) -> wisp.internal_server_error()
  }
}
