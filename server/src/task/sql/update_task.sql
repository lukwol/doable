UPDATE tasks
SET
  name = $2,
  description = $3,
  completed = $4,
  updated_at = NOW()
WHERE id = $1
RETURNING
  id,
  name,
  description,
  completed,
  created_at,
  updated_at
