import gemini
import gemtext/gemtext.{type Gemtext}
import gemtext/parse
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import gleam/uri.{type Uri}
import gopher

const maximum_redirects = 5

pub type Config {
  Config(root_capsule: String)
}

pub fn respond(config: Config, selector: String) -> String {
  let menu = {
    use url <- result.try(
      capsule_url(config, selector)
      |> result.replace_error("The selector is not supported."),
    )
    use #(url, response) <- result.try(request_following_redirects(
      url,
      maximum_redirects,
    ))

    render_response(config, url, response)
  }

  case menu {
    Ok(menu) -> menu
    Error(message) -> gopher.error_menu(message)
  }
}

/// Maps a Gopher selector to the Gemini URL it proxies. Gopher search clients
/// append a tab and the search terms, which become the Gemini query.
pub fn capsule_url(config: Config, selector: String) -> Result(Uri, Nil) {
  case string.split_once(selector, "\t") {
    Ok(#(selector, search)) -> {
      use url <- result.map(capsule_url(config, selector))

      uri.Uri(..url, query: Some(uri.percent_encode(search)))
    }
    Error(Nil) -> {
      let location = case selector {
        "" -> Ok(config.root_capsule)
        "/proxy/" <> capsule -> Ok(capsule)
        "/" <> path -> Ok(config.root_capsule <> "/" <> path)
        _ -> Error(Nil)
      }

      result.try(location, fn(location) { uri.parse("gemini://" <> location) })
    }
  }
}

fn request_following_redirects(
  url: Uri,
  redirects_left: Int,
) -> Result(#(Uri, gemini.Response), String) {
  use response <- result.try(gemini.request(url))

  case response {
    gemini.Redirect(target) if redirects_left > 0 -> {
      use target <- result.try(
        resolve(url, target)
        |> result.replace_error("The capsule redirected to an invalid address."),
      )

      case target.scheme {
        Some("gemini") ->
          request_following_redirects(target, redirects_left - 1)
        _ -> Error("The capsule redirected away from Gemini.")
      }
    }
    _ -> Ok(#(url, response))
  }
}

fn render_response(
  config: Config,
  url: Uri,
  response: gemini.Response,
) -> Result(String, String) {
  case response {
    gemini.Success(mime_type:, body:) -> {
      use document <- result.map(parse_body(mime_type, body))

      document
      |> list.map(route_link(config, url, _))
      |> gopher.gemtext_to_gopher
    }
    gemini.Input(prompt) -> {
      let search = "/7" <> selector(config, uri.Uri(..url, query: None))

      Ok(gopher.gemtext_to_gopher([gemtext.Link(search, Some(prompt))]))
    }
    gemini.Redirect(_) -> Error("The capsule redirected too many times.")
    gemini.Failure(status:, message:) ->
      Error(
        "The capsule responded with status "
        <> int.to_string(status)
        <> ": "
        <> message,
      )
  }
}

fn parse_body(
  mime_type: String,
  body: String,
) -> Result(List(Gemtext), String) {
  case mime_type {
    "" | "text/gemini" <> _ -> Ok(parse.parse_gemtext(body))
    "text/" <> _ ->
      body
      |> string.replace("\r\n", "\n")
      |> string.split("\n")
      |> list.map(gemtext.Text)
      |> Ok
    _ -> Error("The page is " <> mime_type <> ", which Gopher cannot show.")
  }
}

fn route_link(config: Config, page: Uri, line: Gemtext) -> Gemtext {
  case line {
    gemtext.Link(to, title) ->
      gemtext.Link(
        link_target(config, page, to),
        Some(option.unwrap(title, to)),
      )
    _ -> line
  }
}

/// Resolves a link on the given page, mapping Gemini links to Momoka selectors
/// and leaving links for other schemes as absolute URLs.
pub fn link_target(config: Config, page: Uri, link: String) -> String {
  case resolve(page, link) {
    Ok(uri.Uri(scheme: Some("gemini"), ..) as target) ->
      "/1" <> selector(config, target)
    Ok(target) -> uri.to_string(target)
    Error(Nil) -> link
  }
}

fn selector(config: Config, url: Uri) -> String {
  let location = case url.host {
    Some(host) if host == config.root_capsule -> url.path
    Some(host) -> "/proxy/" <> host <> url.path
    None -> url.path
  }
  let query = option.map(url.query, fn(query) { "?" <> query })

  location <> option.unwrap(query, "")
}

fn resolve(page: Uri, link: String) -> Result(Uri, Nil) {
  use relative <- result.try(uri.parse(link))
  use target <- result.map(uri.merge(page, relative))

  let lost_trailing_slash =
    string.ends_with(relative.path, "/") && !string.ends_with(target.path, "/")

  // `uri.merge` drops trailing slashes, which would change how relative links
  // on the linked page resolve.
  case lost_trailing_slash {
    True -> uri.Uri(..target, path: target.path <> "/")
    False -> target
  }
}
