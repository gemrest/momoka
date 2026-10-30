import gemtext/gemtext.{type Gemtext}
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/string
import gleam/uri

pub const default_port = 70

const null_host = "null.host"

pub fn trim_line_ending(line: String) -> String {
  line
  |> string.replace("\n", "")
  |> string.replace("\r", "")
}

pub fn gemtext_to_gopher(document: List(Gemtext)) -> String {
  document
  |> list.flat_map(gemtext_to_menu_lines)
  |> menu
}

pub fn error_menu(message: String) -> String {
  menu([info_line("An error has occurred: " <> message)])
}

fn menu(lines: List(String)) -> String {
  string.concat(list.map(lines, fn(line) { line <> "\r\n" })) <> ".\r\n"
}

fn gemtext_to_menu_lines(line: Gemtext) -> List(String) {
  case line {
    gemtext.Text(text) -> [info_line(text)]
    gemtext.Link(to, title) -> [link_line(to, title)]
    gemtext.Heading(text, depth) -> [
      info_line(string.repeat("#", depth) <> " " <> text),
    ]
    gemtext.ListItem(text) -> [info_line("* " <> text)]
    gemtext.Quote(text) -> [info_line("> " <> text)]
    gemtext.Preformatted(lines) ->
      list.map(lines, fn(line) { info_line("`` " <> line) })
  }
}

fn info_line(text: String) -> String {
  "i" <> escape_field(text) <> "\t\t" <> null_host <> "\t1"
}

fn link_line(to: String, title: String) -> String {
  let host = case uri.parse(to) {
    Ok(uri.Uri(host: Some(host), ..)) -> host
    _ -> null_host
  }

  "h"
  <> escape_field(title)
  <> "\tURL:"
  <> to
  <> "\t"
  <> host
  <> "\t"
  <> int.to_string(default_port)
}

// Tabs separate Gopher menu fields, so any inside the display text would shift
// the selector, host, and port.
fn escape_field(text: String) -> String {
  string.replace(text, "\t", "    ")
}
