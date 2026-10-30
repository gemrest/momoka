import gemtext/gemtext.{type Gemtext}
import gleam/list
import gleam/option.{None, Some}
import gleam/string

pub fn parse_gemtext(text: String) -> List(Gemtext) {
  text
  |> string.replace("\r\n", "\n")
  |> string.split("\n")
  |> parse_lines([])
}

fn parse_lines(lines: List(String), parsed: List(Gemtext)) -> List(Gemtext) {
  case lines {
    // The empty string after a document's final newline is not a line.
    [] | [""] -> list.reverse(parsed)
    ["```" <> _, ..rest] -> {
      let #(body, rest) =
        list.split_while(rest, fn(line) { !string.starts_with(line, "```") })

      parse_lines(list.drop(rest, 1), [gemtext.Preformatted(body), ..parsed])
    }
    [line, ..rest] -> parse_lines(rest, [parse_gemtext_line(line), ..parsed])
  }
}

pub fn parse_gemtext_line(line: String) -> Gemtext {
  case line {
    "=>" <> link -> parse_link(link)
    "###" <> text -> gemtext.Heading(string.trim(text), 3)
    "##" <> text -> gemtext.Heading(string.trim(text), 2)
    "#" <> text -> gemtext.Heading(string.trim(text), 1)
    "* " <> text -> gemtext.ListItem(text)
    ">" <> text -> gemtext.Quote(string.trim_left(text))
    _ -> gemtext.Text(line)
  }
}

fn parse_link(link: String) -> Gemtext {
  let link = link |> string.replace("\t", " ") |> string.trim

  case string.split_once(link, " ") {
    Ok(#(to, title)) -> gemtext.Link(to, Some(string.trim_left(title)))
    Error(Nil) -> gemtext.Link(link, None)
  }
}
