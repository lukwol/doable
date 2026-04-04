import pog

pub type DatabaseError {
  UnexpectedNoRows
  RecordNotFound
  QueryError(pog.QueryError)
}
