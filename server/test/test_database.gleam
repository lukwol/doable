import context.{type Context, type DbPoolName, TestContext}
import gleam/option.{Some}
import pog
import test_config

const test_db_pool_name = "test_db_pool"

@external(erlang, "erlang", "binary_to_atom")
fn binary_to_atom(name: String) -> DbPoolName

pub fn db_pool_name() -> DbPoolName {
  binary_to_atom(test_db_pool_name)
}

pub fn start() -> DbPoolName {
  let config = test_config.load()

  let assert Ok(_) =
    db_pool_name()
    |> pog.default_config
    |> pog.host(config.db_host)
    |> pog.port(config.db_port)
    |> pog.database(config.db_name)
    |> pog.user(config.db_user)
    |> pog.password(Some(config.db_password))
    |> pog.start

  db_pool_name()
}

pub fn with_rollback(ctx: Context, next: fn(Context) -> Nil) -> Nil {
  let _ =
    pog.transaction(context.db_conn(ctx), fn(db_conn) {
      next(TestContext(config: ctx.config, db_conn:))
      // Always rollback by returning Error
      Error("rollback")
    })
  Nil
}
