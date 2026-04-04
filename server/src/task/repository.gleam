import error.{type DatabaseError, QueryError, RecordNotFound, UnexpectedNoRows}
import gleam/bool
import gleam/list
import gleam/result
import pog
import task.{type Task, type TaskInput, Task}
import task/sql

pub fn all_tasks(db_conn: pog.Connection) -> Result(List(Task), DatabaseError) {
  let query_result =
    db_conn
    |> sql.all_tasks
    |> result.map_error(QueryError)
  use pog.Returned(_, rows) <- result.map(query_result)
  use row <- list.map(rows)

  Task(
    id: row.id,
    name: row.name,
    description: row.description,
    completed: row.completed,
  )
}

pub fn create_task(
  db_conn: pog.Connection,
  input: TaskInput,
) -> Result(Task, DatabaseError) {
  let query_result =
    sql.create_task(db_conn, input.name, input.description, input.completed)
    |> result.map_error(QueryError)
  use pog.Returned(_, rows) <- result.try(query_result)
  let row =
    rows
    |> list.first
    |> result.replace_error(UnexpectedNoRows)
  use row <- result.map(row)

  Task(
    id: row.id,
    name: row.name,
    description: row.description,
    completed: row.completed,
  )
}

pub fn get_task(db_conn: pog.Connection, id: Int) -> Result(Task, DatabaseError) {
  let query_result =
    sql.get_task(db_conn, id)
    |> result.map_error(QueryError)
  use pog.Returned(_, rows) <- result.try(query_result)
  let row =
    rows
    |> list.first
    |> result.replace_error(RecordNotFound)
  use row <- result.map(row)

  Task(
    id: row.id,
    name: row.name,
    description: row.description,
    completed: row.completed,
  )
}

pub fn update_task(
  db_conn: pog.Connection,
  task: Task,
) -> Result(Task, DatabaseError) {
  let query_result =
    sql.update_task(
      db_conn,
      task.id,
      task.name,
      task.description,
      task.completed,
    )
    |> result.map_error(QueryError)
  use pog.Returned(_, rows) <- result.try(query_result)
  let row =
    rows
    |> list.first
    |> result.replace_error(RecordNotFound)
  use row <- result.map(row)

  Task(
    id: row.id,
    name: row.name,
    description: row.description,
    completed: row.completed,
  )
}

pub fn delete_task(
  db_conn: pog.Connection,
  id: Int,
) -> Result(Nil, DatabaseError) {
  let query_result =
    sql.delete_task(db_conn, id)
    |> result.map_error(QueryError)
  use pog.Returned(count, _) <- result.try(query_result)
  use <- bool.guard(count == 0, Error(RecordNotFound))

  Ok(Nil)
}
