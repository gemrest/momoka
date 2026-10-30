import gemtext/parse
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/io
import gleam/result
import gleam/string
import gopher

pub type Config {
  Config(root_capsule: String, gemini_proxy: String)
}

pub fn respond(config: Config, selector: String) -> String {
  case fetch_gemtext(config, selector) {
    Ok(gemtext) -> gopher.gemtext_to_gopher(parse.parse_gemtext(gemtext))
    Error(message) -> gopher.error_menu(message)
  }
}

fn fetch_gemtext(config: Config, selector: String) -> Result(String, String) {
  use capsule <- result.try(
    capsule_location(config, selector)
    |> result.replace_error("The selector is not supported."),
  )
  use request <- result.try(
    request.to(config.gemini_proxy <> capsule)
    |> result.replace_error("The capsule address is not valid."),
  )
  use response <- result.try(
    request
    |> request.set_header("user-agent", "momoka")
    |> httpc.send
    |> result.map_error(fn(error) {
      io.println("upstream error: " <> string.inspect(error))

      "The capsule could not be reached."
    }),
  )

  case response.status {
    200 -> Ok(response.body)
    status ->
      Error(
        "The capsule responded with HTTP status "
        <> int.to_string(status)
        <> ".",
      )
  }
}

pub fn capsule_location(
  config: Config,
  selector: String,
) -> Result(String, Nil) {
  case selector {
    "" -> Ok(config.root_capsule)
    "/proxy/" <> capsule -> Ok(capsule)
    "/" <> path -> Ok(config.root_capsule <> "/" <> path)
    _ -> Error(Nil)
  }
}
