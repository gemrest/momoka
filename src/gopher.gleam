import gemtext/gemtext.{type Gemtext}
import gleam/list
import gleam/option.{None, Some}
import gleam/string

pub fn trim_gopher_line_ending(line) {
  string.replace(line, "\r", "") |> string.replace("\n", "")
}

pub fn gemtext_to_gopher(gemtext: List(Gemtext)) -> String {
  gemtext
  |> list.map(fn(line) {
    case line {
      gemtext.PreformattedLine(content) ->
        content
        |> string.split("\n")
        |> list.map(fn(line) {
          case line {
            "```" -> ""
            _ -> "i`` " <> line
          }
        })
        |> string.join("\n")
      _ -> gemtext_line_to_gopher_line(line)
    }
  })
  |> string.join("\n")
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
  <> to
  <> "\t"
  <> extract_domain_from_url(to)
  <> "\t70"
}

pub fn gemtext_line_to_gopher_line(line: Gemtext) -> String {
  case line {
    gemtext.Text(text) -> "i" <> text
    gemtext.Link(to, description) ->
      case description {
        Some(description) -> gopher_link_line(to, description)
        None -> gopher_link_line(to, to)
      }
    gemtext.Heading(text, depth) ->
      "i" <> list.repeat("#", depth) |> string.join("") <> " " <> text
    gemtext.ListLine(text) -> "i* " <> text
    gemtext.BlockquoteLine(text) -> "i> " <> text
    _ -> ""
  }
}
