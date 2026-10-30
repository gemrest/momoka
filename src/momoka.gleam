import envoy
import gemini
import gleam/bit_array
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/option.{None}
import gleam/otp/actor
import gleam/result
import gleam/string
import glisten.{Packet}
import glisten/tcp

const default_port = 70

pub fn main() {
  // Momoka fetches Gemini content through a
  // [September](https://github.com/gemrest/september) instance, which serves
  // raw Gemtext over HTTPS, rather than speaking Gemini itself.
  let config =
    gemini.Config(
      root_capsule: envoy.get("ROOT") |> result.unwrap("fuwn.me"),
      gemini_proxy: envoy.get("GEMINI_PROXY")
        |> result.unwrap("https://fuwn.me/raw/"),
    )
  let port = case envoy.get("PORT") {
    Ok(port) -> {
      let assert Ok(port) = int.parse(port) as "PORT must be an integer"

      port
    }
    Error(Nil) -> default_port
  }
  let assert Ok(_) =
    glisten.handler(fn(_connection) { #(config, None) }, handle_message)
    |> glisten.serve(port)

  process.sleep_forever()
}

fn handle_message(message, config, connection: glisten.Connection(a)) {
  let assert Packet(message) = message
  let assert Ok(_) =
    glisten.send(connection, gemini.get_gemtext_from_capsule(config, message))
  let assert Ok(_) = tcp.shutdown(connection.socket)

  io.println(
    "request: "
    <> {
      case bit_array.to_string(message) {
        Ok(path) ->
          case path |> string.replace("\r\n", "") {
            "" -> "/"
            path -> path
          }
        _ -> "unknown"
      }
    },
  )

  actor.continue(config)
}
