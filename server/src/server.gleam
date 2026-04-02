import config
import context.{Context}
import database
import gleam/erlang/process
import mist
import router
import wisp
import wisp/wisp_mist

pub fn main() -> Nil {
  let config = config.load()
  let db_pool_name = database.start(config)
  let context = Context(config:, db_pool_name:)

  wisp.configure_logger()

  let assert Ok(_) =
    router.handle_request(_, context)
    |> wisp_mist.handler(config.secret_key_base)
    |> mist.new
    |> mist.bind(config.server_host)
    |> mist.port(config.server_port)
    |> mist.start

  process.sleep_forever()
}
