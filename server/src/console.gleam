import config
import context.{Context}
import database
import gleam/dynamic.{type Dynamic}
import gleam/erlang/atom
import pog

@external(erlang, "shell", "strings")
fn shell_strings(enabled: Bool) -> Dynamic

@external(erlang, "application", "ensure_all_started")
fn ensure_all_started(app: atom.Atom) -> Dynamic

pub fn init() -> pog.Connection {
  let _ = shell_strings(True)
  let _ = ensure_all_started(atom.create("pgo"))
  let config = config.load()
  let db_pool_name = database.start(config)
  let context = Context(config:, db_pool_name:)
  context.db_conn(context)
}
