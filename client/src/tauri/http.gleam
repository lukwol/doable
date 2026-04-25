import gleam/fetch.{type FetchError, type FetchRequest, type FetchResponse}
import gleam/javascript/promise.{type Promise}

@external(javascript, "./http_ffi.js", "raw_send")
pub fn raw_send(a: FetchRequest) -> Promise(Result(FetchResponse, FetchError))
