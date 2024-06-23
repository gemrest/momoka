import gemtext/gemtext.{type Gemtext}
import gleam/list
import gleam/string

pub fn combine_adjacent_blockquote_lines(lines: List(Gemtext)) -> List(Gemtext) {
  case lines {
    [gemtext.BlockquoteLine(a), gemtext.BlockquoteLine(b), ..rest] ->
      combine_adjacent_blockquote_lines([
        gemtext.Blockquote(string.join([a, b], "\n")),
        ..rest
      ])
    [gemtext.Blockquote(a), gemtext.BlockquoteLine(b), ..rest] ->
      combine_adjacent_blockquote_lines([
        gemtext.Blockquote(string.join([a, b], "\n")),
        ..rest
      ])
    [g, ..rest] -> list.append([g], combine_adjacent_blockquote_lines(rest))
    [] -> []
  }
}
