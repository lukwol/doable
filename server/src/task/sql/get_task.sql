SELECT
  id,
  name,
  description,
  completed,
  created_at,
  updated_at
FROM tasks
WHERE id = $1
