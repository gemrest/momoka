import envoy
import gleam/bit_array
import gleam/bytes_builder
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/option.{None}
import gleam/otp/actor
import gleam/result
import glisten.{Packet}
import glisten/tcp
import gopher
import proxy

pub fn main() {
  // Momoka fetches Gemini content through a
  // [September](https://github.com/gemrest/september) instance, which serves
  // raw Gemtext over HTTPS, rather than speaking Gemini itself.
  let config =
    proxy.Config(
      root_capsule: envoy.get("ROOT") |> result.unwrap("fuwn.me"),
      gemini_proxy: envoy.get("GEMINI_PROXY")
        |> result.unwrap("https://fuwn.me/raw/"),
    )
  let port = case envoy.get("PORT") {
    Ok(port) -> {
      let assert Ok(port) = int.parse(port) as "PORT must be an integer"

      port
    }
    Error(Nil) -> gopher.default_port
  }
  let assert Ok(_) =
    glisten.handler(fn(_connection) { #(config, None) }, handle_message)
    |> glisten.serve(port)

  process.sleep_forever()
}

fn handle_message(message, config, connection: glisten.Connection(a)) {
  let assert Packet(message) = message
  let selector =
    bit_array.to_string(message) |> result.map(gopher.trim_line_ending)
  let response = case selector {
    Ok(selector) -> proxy.respond(config, selector)
    Error(Nil) -> gopher.error_menu("The selector is not valid UTF-8.")
  }
  let assert Ok(_) =
    glisten.send(connection, bytes_builder.from_string(response))
  let assert Ok(_) = tcp.shutdown(connection.socket)

  io.println(
    "request: "
    <> case selector {
      Ok("") -> "/"
      Ok(selector) -> selector
      Error(Nil) -> "unknown"
    },
  )

  actor.continue(config)
}
