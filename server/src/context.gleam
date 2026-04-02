import config.{type Config}
import gleam/erlang/process
import pog

pub type DbPoolName =
  process.Name(pog.Message)

pub type Context {
  Context(config: Config, db_pool_name: DbPoolName)
}

pub fn db_conn(ctx: Context) -> pog.Connection {
  pog.named_connection(ctx.db_pool_name)
}
