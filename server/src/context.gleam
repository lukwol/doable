import config.{type Config}
import gleam/erlang/process
import pog

pub type DbPoolName =
  process.Name(pog.Message)

pub type Context {
  Context(config: Config, db_pool_name: DbPoolName)
  TestContext(config: Config, db_conn: pog.Connection)
}

pub fn db_conn(ctx: Context) -> pog.Connection {
  case ctx {
    Context(_, db_pool_name) -> pog.named_connection(db_pool_name)
    TestContext(_, db_conn) -> db_conn
  }
}
