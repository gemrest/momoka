import gemtext/parse
import gleam/bytes_builder.{type BytesBuilder}
import gleam/http/request
import gleam/httpc
import gleam/result
import gleam/string
import gopher

pub type Config {
  Config(root_capsule: String, gemini_proxy: String)
}

pub fn respond(config: Config, selector: String) -> BytesBuilder {
  case result.try(capsule_url(config, selector), request.to) {
    Ok(request) -> {
      case httpc.send(request) {
        Ok(response) ->
          bytes_builder.from_string(
            gopher.gemtext_to_gopher(parse.parse_gemtext(response.body))
            <> "\r\n",
          )
        Error(error) -> error_response(string.inspect(error))
      }
    }
    Error(error) -> error_response(string.inspect(error))
  }
}

fn capsule_url(config: Config, selector: String) -> Result(String, Nil) {
  case selector {
    "" -> Ok(config.gemini_proxy <> config.root_capsule)
    "/proxy/" <> capsule -> Ok(config.gemini_proxy <> capsule)
    "/" <> path -> Ok(config.gemini_proxy <> config.root_capsule <> "/" <> path)
    _ -> Error(Nil)
  }
}

pub fn error_response(message: String) -> BytesBuilder {
  bytes_builder.from_string(
    {
      { "iAn error has occurred: " <> message }
      |> gopher.terminate_text_line
    }
    <> "\r\n",
  )
}
