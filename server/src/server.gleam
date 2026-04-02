import config
import gleam/erlang/process
import mist
import router
import wisp
import wisp/wisp_mist

pub fn main() -> Nil {
  let config = config.load()

  wisp.configure_logger()

  let assert Ok(_) =
    router.handle_request
    |> wisp_mist.handler(config.secret_key_base)
    |> mist.new
    |> mist.bind(config.server_host)
    |> mist.port(config.server_port)
    |> mist.start

  process.sleep_forever()
}
