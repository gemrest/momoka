import gleam/list
import gleam/string

pub type Gemtext {
  Text(String)
  Link(to: String, title: String)
  Heading(String, depth: Int)
  ListItem(String)
  Quote(String)
  Preformatted(lines: List(String))
}

pub fn parse(text: String) -> List(Gemtext) {
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

      parse_lines(list.drop(rest, 1), [Preformatted(body), ..parsed])
    }
    [line, ..rest] -> parse_lines(rest, [parse_line(line), ..parsed])
  }
}

pub fn parse_line(line: String) -> Gemtext {
  case line {
    "=>" <> link -> parse_link(link)
    "###" <> text -> Heading(string.trim(text), 3)
    "##" <> text -> Heading(string.trim(text), 2)
    "#" <> text -> Heading(string.trim(text), 1)
    "* " <> text -> ListItem(text)
    ">" <> text -> Quote(string.trim_start(text))
    _ -> Text(line)
  }
}

fn parse_link(link: String) -> Gemtext {
  let link = link |> string.replace("\t", " ") |> string.trim

  case string.split_once(link, " ") {
    Ok(#(to, title)) -> Link(to, string.trim_start(title))
    Error(Nil) -> Link(link, link)
  }
}
