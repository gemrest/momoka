import gemtext/blockquote
import gemtext/gemtext.{type Gemtext}
import gemtext/heading
import gemtext/list as gemtext_list
import gemtext/preformatted_block
import gleam/list
import gleam/option.{None, Some}
import gleam/string

pub fn parse_gemtext_line(line) -> Gemtext {
  let trimmed_line = string.trim(line)

  case string.split(trimmed_line, " ") {
    ["=>", to] -> gemtext.Link(to, None)
    ["=>", to, ..title] -> gemtext.Link(to, Some(string.join(title, " ")))
    [">", ..rest] ->
      gemtext.BlockquoteLine(string.trim_left(string.join(rest, " ")))
    ["*", ..rest] -> gemtext.ListLine(string.trim_left(string.join(rest, " ")))
    [""] -> gemtext.Whitespace
    _ -> {
      case string.to_graphemes(trimmed_line) {
        ["#", ..rest] ->
          gemtext.Heading(
            string.trim_left(string.replace(string.join(rest, ""), "#", "")),
            heading.count_leading_hashes(line),
          )
        ["`", "`", "`", ..rest] ->
          gemtext.PreformattedLine(string.trim_left(
            "```\n" <> string.join(rest, ""),
          ))
        _ -> gemtext.Text(line)
      }
    }
  }
}

pub fn parse_gemtext(text: String) -> List(Gemtext) {
  string.split(text, "\n")
  |> preformatted_block.group_adjacent_preformatted_block_lines
  |> list.map(parse_gemtext_line)
  |> gemtext_list.group_adjacent_list_items
  |> blockquote.combine_adjacent_blockquote_lines
}

pub fn parse_gemtext_raw(text: String) -> List(Gemtext) {
  string.split(text, "\n")
  |> preformatted_block.group_adjacent_preformatted_block_lines
  |> list.map(parse_gemtext_line)
}
