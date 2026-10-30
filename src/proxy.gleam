import gemtext/gemtext.{type Gemtext}
import gemtext/parse
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/result
import gleam/string
import gleam/uri
import gopher

pub type Config {
  Config(root_capsule: String, gemini_proxy: String)
}

pub fn respond(config: Config, selector: String) -> String {
  let document = {
    use capsule <- result.try(
      capsule_location(config, selector)
      |> result.replace_error("The selector is not supported."),
    )
    use gemtext <- result.try(fetch_gemtext(config, capsule))

    parse.parse_gemtext(gemtext)
    |> list.map(route_link(config, capsule, _))
    |> Ok
  }

  case document {
    Ok(document) -> gopher.gemtext_to_gopher(document)
    Error(message) -> gopher.error_menu(message)
  }
}

fn fetch_gemtext(config: Config, capsule: String) -> Result(String, String) {
  use request <- result.try(
    request.to(config.gemini_proxy <> capsule)
    |> result.replace_error("The capsule address is not valid."),
  )
  use response <- result.try(
    httpc.configure()
    |> httpc.follow_redirects(True)
    |> httpc.dispatch(request.set_header(request, "user-agent", "momoka"))
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

fn route_link(config: Config, capsule: String, line: Gemtext) -> Gemtext {
  case line {
    gemtext.Link(to, title) ->
      gemtext.Link(
        link_target(config, capsule, to),
        Some(option.unwrap(title, to)),
      )
    _ -> line
  }
}

/// Resolves a link on the given capsule page, mapping Gemini links to Momoka
/// selectors and leaving links for other schemes as absolute URLs.
pub fn link_target(config: Config, capsule: String, link: String) -> String {
  let target = {
    use page <- result.try(uri.parse("gemini://" <> capsule))
    use relative <- result.try(uri.parse(link))
    use target <- result.map(uri.merge(page, relative))

    let lost_trailing_slash =
      string.ends_with(relative.path, "/")
      && !string.ends_with(target.path, "/")

    // `uri.merge` drops trailing slashes, which would change how relative
    // links on the linked page resolve.
    case lost_trailing_slash {
      True -> uri.Uri(..target, path: target.path <> "/")
      False -> target
    }
  }

  case target {
    Ok(uri.Uri(scheme: Some("gemini"), host: Some(host), path:, query:, ..)) -> {
      let location = case host == config.root_capsule {
        True -> path
        False -> "/proxy/" <> host <> path
      }
      let query = option.map(query, fn(query) { "?" <> query })

      "/1" <> location <> option.unwrap(query, "")
    }
    Ok(target) -> uri.to_string(target)
    Error(Nil) -> link
  }
}
