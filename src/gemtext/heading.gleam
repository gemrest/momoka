import gleam/string

pub fn count_leading_hashes(line: String) -> Int {
  do_count_leading_hashes(string.to_graphemes(line), 0)
}

fn do_count_leading_hashes(characters: List(String), accumulator: Int) -> Int {
  case characters {
    [c, ..rest] -> {
      case c {
        "#" -> do_count_leading_hashes(rest, accumulator + 1)
        _ -> accumulator
      }
    }
    _ -> accumulator
  }
}
