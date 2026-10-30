import gleam/bit_array
import gleam/dynamic.{type Dynamic}
import gleam/int
import gleam/io
import gleam/option
import gleam/result
import gleam/string
import gleam/uri.{type Uri}

const default_port = 1965

const timeout_milliseconds = 30_000

const maximum_response_bytes = 5_000_000

pub type Response {
  Input(prompt: String)
  Success(mime_type: String, body: String)
  Redirect(url: String)
  Failure(status: Int, message: String)
}

@external(erlang, "momoka_ffi", "gemini_request")
fn gemini_request(
  host: String,
  port: Int,
  request: String,
  timeout_milliseconds: Int,
  maximum_bytes: Int,
) -> Result(BitArray, Dynamic)

pub fn request(url: Uri) -> Result(Response, String) {
  use host <- result.try(option.to_result(
    url.host,
    "The capsule address has no host.",
  ))

  let url = case url.path {
    "" -> uri.Uri(..url, path: "/")
    _ -> url
  }

  use response <- result.try(
    gemini_request(
      host,
      option.unwrap(url.port, default_port),
      uri.to_string(url) <> "\r\n",
      timeout_milliseconds,
      maximum_response_bytes,
    )
    |> result.map_error(fn(reason) {
      io.println("gemini error: " <> string.inspect(reason))

      "The capsule could not be reached."
    }),
  )
  use response <- result.try(
    bit_array.to_string(response)
    |> result.replace_error("The capsule's response is not UTF-8 text."),
  )

  parse_response(response)
}

pub fn parse_response(response: String) -> Result(Response, String) {
  let malformed = "The capsule's response is malformed."

  use #(header, body) <- result.try(
    string.split_once(response, "\r\n") |> result.replace_error(malformed),
  )

  let #(status, meta) =
    string.split_once(header, " ") |> result.unwrap(#(header, ""))

  use status <- result.try(int.parse(status) |> result.replace_error(malformed))

  case status / 10 {
    1 -> Ok(Input(meta))
    2 -> Ok(Success(meta, body))
    3 -> Ok(Redirect(meta))
    _ -> Ok(Failure(status, meta))
  }
}
