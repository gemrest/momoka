import envoy
import gleam/bit_array
import gleam/bytes_tree
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/option.{None}
import gleam/result
import glisten.{Packet}
import glisten/transport
import gopher
import proxy

pub fn main() {
  let config =
    proxy.Config(root_capsule: envoy.get("ROOT") |> result.unwrap("fuwn.net"))
  let port = case envoy.get("PORT") {
    Ok(port) -> {
      let assert Ok(port) = int.parse(port) as "PORT must be an integer"

      port
    }
    Error(Nil) -> gopher.default_port
  }
  let assert Ok(_) =
    glisten.new(fn(_connection) { #(config, None) }, handle_message)
    |> glisten.bind("0.0.0.0")
    |> glisten.start(port)

  process.sleep_forever()
}

fn handle_message(config, message, connection: glisten.Connection(a)) {
  let assert Packet(message) = message
  let selector =
    bit_array.to_string(message) |> result.map(gopher.trim_line_ending)
  let response = case selector {
    Ok(selector) -> proxy.respond(config, selector)
    Error(Nil) -> gopher.error_menu("The selector is not valid UTF-8.")
  }

  // A client that disconnects early has nothing left to receive, so these
  // failures need no handling.
  let _ = glisten.send(connection, bytes_tree.from_string(response))
  let _ = transport.shutdown(connection.transport, connection.socket)

  io.println(
    "request: "
    <> case selector {
      Ok("") -> "/"
      Ok(selector) -> selector
      Error(Nil) -> "unknown"
    },
  )

  glisten.continue(config)
}
