import gemtext/parse
import gleam/http/request
import gleam/httpc
import gleam/result
import gleam/string
import gopher

pub type Config {
  Config(root_capsule: String, gemini_proxy: String)
}

pub fn respond(config: Config, selector: String) -> String {
  case result.try(capsule_url(config, selector), request.to) {
    Ok(request) -> {
      case httpc.send(request.set_header(request, "user-agent", "momoka")) {
        Ok(response) ->
          gopher.gemtext_to_gopher(parse.parse_gemtext(response.body))
        Error(error) -> gopher.error_menu(string.inspect(error))
      }
    }
    Error(error) -> gopher.error_menu(string.inspect(error))
  }
}

pub fn capsule_url(config: Config, selector: String) -> Result(String, Nil) {
  case selector {
    "" -> Ok(config.gemini_proxy <> config.root_capsule)
    "/proxy/" <> capsule -> Ok(config.gemini_proxy <> capsule)
    "/" <> path -> Ok(config.gemini_proxy <> config.root_capsule <> "/" <> path)
    _ -> Error(Nil)
  }
}
