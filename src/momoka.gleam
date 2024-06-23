import envoy
import gemini
import gleam/erlang/process
import gleam/int
import gleam/option.{None}
import gleam/otp/actor
import glisten.{Packet}
import tcp

pub fn main() {
  let assert Ok(_) =
    glisten.handler(
      fn(_connection) { #(Nil, None) },
      fn(message, state, connection) {
        let assert Packet(message) = message
        let assert Ok(_) =
          glisten.send(connection, gemini.get_gemtext_from_capsule(message))
        let assert Ok(_) = tcp.close_connection(connection)

        actor.continue(state)
      },
    )
    |> glisten.serve(case envoy.get("PORT") {
      Ok(port) -> {
        case int.base_parse(port, 10) {
          Ok(port) -> port
          _ -> 70
        }
      }
      _ -> 70
    })

  process.sleep_forever()
}
