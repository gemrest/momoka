import gemtext/parse
import gleam/bit_array
import gleam/bytes_builder
import gleam/http/request
import gleam/httpc
import gleam/string
import gopher

pub type Config {
  Config(root_capsule: String, gemini_proxy: String)
}

pub fn get_gemtext_from_capsule(config: Config, message) {
  let Config(root_capsule:, gemini_proxy:) = config

  case
    case bit_array.to_string(message) {
      Ok(path) -> {
        case string.split(path, "/") {
          ["\r\n"] | ["\n"] -> request.to(gemini_proxy <> root_capsule)
          ["", "proxy", ..route] ->
            request.to(
              gemini_proxy
              <> gopher.trim_gopher_line_ending(string.join(route, "/")),
            )
          ["", ..path] ->
            request.to(
              gemini_proxy
              <> root_capsule
              <> "/"
              <> gopher.trim_gopher_line_ending(string.join(path, "/")),
            )
          _ -> Error(Nil)
        }
      }
      _ -> Error(Nil)
    }
  {
    Ok(request) -> {
      case httpc.send(request) {
        Ok(response) ->
          bytes_builder.from_string(
            gopher.gemtext_to_gopher(parse.parse_gemtext(response.body))
            <> "\r\n",
          )
        Error(error) -> error_response(error)
      }
    }
    Error(error) -> error_response(error)
  }
}

fn error_response(error) {
  bytes_builder.from_string(
    {
      { "iAn error has occurred: " <> string.inspect(error) }
      |> gopher.terminate_text_line
    }
    <> "\r\n",
  )
}
