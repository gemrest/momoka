import envoy
import gemtext/parse
import gleam/bit_array
import gleam/bytes_builder
import gleam/http/request
import gleam/httpc
import gleam/string
import gopher

pub fn get_gemtext_from_capsule(message) {
  let root_capsule = case envoy.get("ROOT") {
    Ok(capsule) -> capsule
    _ -> "fuwn.me"
  }
  // Gleam isn't mature enough to even have an SSL/TLS libraries that I could
  // find, and Erlang FFI is unclear, so Momoka uses the
  // [September](https://github.com/gemrest/september) proxy deployed at
  // <https://fuwn.me> to fetch the raw Gemini content.
  //
  // I'm sure as the language grows, this will be replaced with a more direct
  // approach.
  let gemini_proxy = case envoy.get("GEMINI_PROXY") {
    Ok(proxy) -> proxy
    _ -> "https://fuwn.me/raw/"
  }
  let assert Ok(request) = case bit_array.to_string(message) {
    Ok(path) -> {
      case path {
        "/\r\n" | "\r\n" | "\n" -> request.to(gemini_proxy <> root_capsule)
        "/proxy/" <> route ->
          request.to(gemini_proxy <> string.replace(route, "\r\n", ""))
        "/" <> path ->
          request.to(
            gemini_proxy
            <> root_capsule
            <> "/"
            <> string.replace(path, "\r\n", ""),
          )
        _ -> request.to(root_capsule <> string.replace(path, "\r\n", ""))
      }
    }
    _ -> request.to(root_capsule)
  }
  let assert Ok(response) = httpc.send(request)

  bytes_builder.from_string(
    gopher.gemtext_to_gopher(parse.parse_gemtext_raw(response.body)) <> "\r\n",
  )
}
