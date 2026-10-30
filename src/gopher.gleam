import gemtext/gemtext.{type Gemtext}
import gleam/list
import gleam/option.{None, Some}
import gleam/string

pub fn trim_line_ending(line) {
  line
  |> string.replace("\n", "")
  |> string.replace("\r", "")
}

pub fn terminate_text_line(line) {
  line <> "\tnull.host\t1\t70"
}

pub fn gemtext_to_gopher(gemtext: List(Gemtext)) -> String {
  {
    gemtext
    |> list.map(fn(line) {
      case line {
        gemtext.Preformatted(lines) ->
          ["", ..list.map(lines, fn(line) { "i`` " <> line })]
          |> list.append([""])
          |> string.join("\n")
        _ -> gemtext_line_to_gopher_line(line)
      }
    })
    |> string.join("\r\n")
    <> "."
  }
  |> string.replace("\r\n\r\n.", "\r\n.")
  |> string.split("\r\n")
  |> list.map(fn(line) {
    case line {
      "" -> "i" |> terminate_text_line
      _ -> line
    }
  })
  |> string.join("\r\n")
}

fn extract_domain_from_url(url: String) -> String {
  case string.split(url, "://") {
    [_, rest] -> {
      case string.split(rest, "/") {
        [domain, _] -> domain
        _ -> rest
      }
    }
    _ -> "null.host"
  }
}

fn gopher_link_line(to, description) {
  "h"
  <> description
  <> "\tURL:"
  <> {
    case string.starts_with(to, "/") {
      True -> "/1" <> to
      False -> to
    }
  }
  <> "\t"
  <> extract_domain_from_url(to)
  <> "\t70"
}

pub fn gemtext_line_to_gopher_line(line: Gemtext) -> String {
  case line {
    gemtext.Text("") -> ""
    gemtext.Text(text) -> { "i" <> text } |> terminate_text_line
    gemtext.Link(to, description) ->
      case description {
        Some(description) -> gopher_link_line(to, description)
        None -> gopher_link_line(to, to)
      }
    gemtext.Heading(text, depth) ->
      { "i" <> list.repeat("#", depth) |> string.join("") <> " " <> text }
      |> terminate_text_line
    gemtext.ListItem(text) -> { "i* " <> text } |> terminate_text_line
    gemtext.Quote(text) -> { "i> " <> text } |> terminate_text_line
    gemtext.Preformatted(_) -> ""
  }
}
