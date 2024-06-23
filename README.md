# 🏕️ Momoka

> A Gemini-to-Gopher Proxy

Momoka is a Gopher proxy that sits in between Gopher clients and Gemini servers.
It translates any Gemini requests containing Gemtext into Gopher-compatible
responses.

Momoka is written in under 300 (280) lines of code and written in the functional
[Gleam](https://gleam.run). It's designed to be small and simple.

## Usage

If you'd like to test out a production deployment of Momoka, you can visit
[`gopher://fuwn.me:70/1`](gopher://fuwn.me:70/1).

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

By default, top-level requests, like `gopher://fuwn.me/1`, are proxied to
their mapped Gemini equivalents. Here are a few examples.

- [`gopher://fuwn.me`](gopher://fuwn.me) =>
  [`gemini://fuwn.me`](gemini://fuwn.me)
- [`gopher://fuwn.me/1`](gopher://fuwn.me/1) =>
  [`gemini://fuwn.me`](gemini://fuwn.me)
- [`gopher://fuwn.me/1/index2`](gopher://fuwn.me/1/index2) =>
  [`gemini://fuwn.me/index2`](gemini://fuwn.me/index2)

Prepending `/proxy/` to the path will allow you to proxy any Gemini server.
Here are a few examples.

- [`gopher://fuwn.me/1/proxy/geminiprotocol.net`](gopher://fuwn.me/1/proxy/geminiprotocol.net)
  => [`gemini://geminiprotocol.net`](gemini://geminiprotocol.net)
- [`gopher://fuwn.me/1/proxy/fuwn.me/index2`](gopher://fuwn.me/1/proxy/fuwn.me/index2)
  => [`gemini://fuwn.me/index2`](`gemini://fuwn.me/index2`)

### Configuration

Momoka contains three environment variables that can be set to your liking.

- `ROOT` – The root Gemini capsule to proxy for top-level requests (defaults to
  `fuwn.me`)
- `PORT` – The port to listen on for Gopher clients (defaults to `70`)
- `GEMINI_PROXY` – A raw-Gemtext producing Gemini-to-HTTP proxy. (defaults to
  the [fuwn.me](https://fuwn.me)
  [September](https://github.com/gemrest/september) instance)

## GemRest

I'm also the author of [GemRest](https://github.com/gemrest), the largest
organisation of Gemini-oriented software, tooling, and libraries. If you're
interested in Gemini, I'd recommend checking it out.

## Licence

This project is licensed with the [GNU General Public License v3.0](./LICENSE).
