import context.{type Context, TestContext}
import gleam/erlang/process
import pog
import test_config
import test_database

pub fn get() -> Context {
  let config = test_config.load()
  let db_pool_name = test_database.db_pool_name()
  let assert Ok(_) = process.named(db_pool_name)
  let db_conn = pog.named_connection(db_pool_name)
  TestContext(config:, db_conn:)
}
