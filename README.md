# 🏕️ Momoka

> A Gemini-to-Gopher proxy that bridges the smolweb to even more smolweb

Momoka is a [Gopher](https://www.rfc-editor.org/info/rfc1436) server that
proxies [Gemini](https://fuwn.net/proxy/geminiprotocol.net/) capsules. It fetches
the Gemini page a Gopher client asks for and converts its Gemtext into a Gopher
menu. Momoka is written in [Gleam](https://gleam.run).

<br>

The screenshot below shows the [Lagrange](https://gmi.skyjake.fi/lagrange/)
client displaying the Gopher and Gemini versions of a page side by side.

<p align="center">
  <br>
  <img src="https://i.imgur.com/07aLdRj.png" width="75%">
</p>

## Usage

A public instance runs at [`gopher://fuwn.net:70/1`](gopher://fuwn.net:70/1).

### Local

```bash
$ git clone git@github.com:Fuwn/momoka.git
$ cd momoka
$ gleam run
$ # or
$ nix run
```

### Docker

```shell
docker run -p '70:70' --rm fuwn/momoka:latest
```

### Proxy

Momoka maps top-level requests, like `gopher://fuwn.net/1`, to the same path on
the root capsule. For example:

- [`gopher://fuwn.net`](gopher://fuwn.net) =>
  [`gemini://fuwn.net`](gemini://fuwn.net)
- [`gopher://fuwn.net/1`](gopher://fuwn.net/1) =>
  [`gemini://fuwn.net`](gemini://fuwn.net)
- [`gopher://fuwn.net/1/blog`](gopher://fuwn.net/1/blog) =>
  [`gemini://fuwn.net/blog`](gemini://fuwn.net/blog)

To reach any other capsule, prefix its address with `/proxy/`. For example:

- [`gopher://fuwn.net/1/proxy/geminiprotocol.net`](gopher://fuwn.net/1/proxy/geminiprotocol.net)
  => [`gemini://geminiprotocol.net`](gemini://geminiprotocol.net)
- [`gopher://fuwn.net/1/proxy/fuwn.net/blog`](gopher://fuwn.net/1/proxy/fuwn.net/blog)
  => [`gemini://fuwn.net/blog`](gemini://fuwn.net/blog)

Momoka rewrites links to Gemini pages, including relative links, so following
one fetches the page through Momoka. Pages that ask for input, like search
engines, become Gopher search items.

Momoka speaks Gemini directly, so it needs outbound access to port 1965. Most
capsules use self-signed certificates, so Momoka does not verify them.

### Configuration

Momoka reads two environment variables.

- `ROOT` is the capsule that top-level requests go to. It defaults to `fuwn.net`.
- `PORT` is the port Momoka listens on. It defaults to `70`, and Momoka exits on
  startup if the value is not an integer.

## GemRest

I'm also the author of [GemRest](https://github.com/gemrest), the largest
organisation of Gemini-oriented software, tooling, and libraries. If you're
interested in Gemini, I'd recommend checking it out.

## Licence

This project is licensed under the [GNU General Public License v3.0](./LICENSE).
