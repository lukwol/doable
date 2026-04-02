import config.{type Config}
import context.{type DbPoolName}
import gleam/erlang/process
import gleam/option.{Some}
import gleam/otp/static_supervisor as supervisor
import pog

pub fn start(config: Config) -> DbPoolName {
  let db_pool_name = process.new_name("db")
  let db_pool =
    db_pool_name
    |> pog.default_config
    |> pog.host(config.db_host)
    |> pog.port(config.db_port)
    |> pog.database(config.db_name)
    |> pog.user(config.db_user)
    |> pog.password(Some(config.db_password))
    |> pog.supervised
  let assert Ok(_) =
    supervisor.new(supervisor.RestForOne)
    |> supervisor.add(db_pool)
    |> supervisor.start
  db_pool_name
}
