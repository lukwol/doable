import gleeunit
import test_database

pub fn main() -> Nil {
  test_database.start()

  gleeunit.main()
}
