import gleam/list
import gleam/string

pub fn group_adjacent_preformatted_block_lines(
  lines: List(String),
) -> List(String) {
  case lines {
    ["```", desc, ..rest] -> {
      let #(body, rest) = do_group_adjacent_preformatted_block_lines(rest, [])
      list.append(
        ["```" <> desc <> "\n" <> body <> "\n```"],
        group_adjacent_preformatted_block_lines(rest),
      )
    }
    [line, ..rest] ->
      list.append([line], group_adjacent_preformatted_block_lines(rest))
    [] -> []
  }
}

fn do_group_adjacent_preformatted_block_lines(
  lines: List(String),
  accumulator: List(String),
) {
  case lines {
    ["```", ..rest] -> #(string.join(accumulator, "\n"), rest)
    [line, ..rest] ->
      do_group_adjacent_preformatted_block_lines(
        rest,
        list.append(accumulator, [line]),
      )
    [] -> #(string.join(accumulator, "\n"), [])
  }
}
