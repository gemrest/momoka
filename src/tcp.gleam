import gleam/erlang/atom.{type Atom}
import glisten
import glisten/socket.{type Socket, type SocketReason}

@external(erlang, "glisten_tcp_ffi", "shutdown")
fn do_shutdown(socket: Socket, write: Atom) -> Result(Nil, SocketReason)

pub fn shutdown(socket: Socket) -> Result(Nil, SocketReason) {
  let assert Ok(write) = atom.from_string("write")

  do_shutdown(socket, write)
}

pub fn close_connection(connection: glisten.Connection(a)) {
  shutdown(connection.socket)
}
