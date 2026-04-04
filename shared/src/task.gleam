import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}

pub type Task {
  Task(id: Int, name: String, description: String, completed: Bool)
}

pub fn to_task_input(task: Task) -> TaskInput {
  TaskInput(
    name: task.name,
    description: task.description,
    completed: task.completed,
  )
}

pub fn task_decoder() -> Decoder(Task) {
  use id <- decode.field("id", decode.int)
  use name <- decode.field("name", decode.string)
  use description <- decode.field("description", decode.string)
  use completed <- decode.field("completed", decode.bool)
  decode.success(Task(id:, name:, description:, completed:))
}

pub fn task_to_json(task: Task) -> Json {
  json.object([
    #("id", json.int(task.id)),
    #("name", json.string(task.name)),
    #("description", json.string(task.description)),
    #("completed", json.bool(task.completed)),
  ])
}

pub type TaskInput {
  TaskInput(name: String, description: String, completed: Bool)
}

pub fn to_task(input: TaskInput, id: Int) -> Task {
  Task(
    id: id,
    name: input.name,
    description: input.description,
    completed: input.completed,
  )
}

pub fn task_input_decoder() -> Decoder(TaskInput) {
  use name <- decode.field("name", decode.string)
  use description <- decode.field("description", decode.string)
  use completed <- decode.optional_field("completed", False, decode.bool)
  decode.success(TaskInput(name:, description:, completed:))
}

pub fn task_input_to_json(input: TaskInput) -> Json {
  json.object([
    #("name", json.string(input.name)),
    #("description", json.string(input.description)),
    #("completed", json.bool(input.completed)),
  ])
}
