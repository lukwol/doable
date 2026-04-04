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
