SELECT
  id,
  name,
  description,
  completed,
  created_at,
  updated_at
FROM tasks
ORDER BY created_at DESC, id DESC
