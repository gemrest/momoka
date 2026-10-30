import gleam/result
import gleam/uri
import gleeunit/should
import proxy

const config = proxy.Config(root_capsule: "fuwn.net")

fn capsule_url(selector: String) -> Result(String, Nil) {
  proxy.capsule_url(config, selector) |> result.map(uri.to_string)
}

fn link_target(page: String, link: String) -> String {
  let assert Ok(page) = uri.parse(page)

  proxy.link_target(config, page, link)
}

pub fn root_selector_test() {
  capsule_url("")
  |> should.equal(Ok("gemini://fuwn.net"))
}

pub fn root_capsule_path_test() {
  capsule_url("/index2")
  |> should.equal(Ok("gemini://fuwn.net/index2"))
}

pub fn proxied_capsule_test() {
  capsule_url("/proxy/geminiprotocol.net/docs")
  |> should.equal(Ok("gemini://geminiprotocol.net/docs"))
}

pub fn search_selector_test() {
  capsule_url("/proxy/kennedy.gemi.dev/search\tgleam language")
  |> should.equal(Ok("gemini://kennedy.gemi.dev/search?gleam%20language"))
}

pub fn unsupported_selector_test() {
  capsule_url("index2")
  |> should.equal(Error(Nil))
}

pub fn absolute_root_capsule_link_test() {
  link_target("gemini://fuwn.net", "/index2")
  |> should.equal("/1/index2")
}

pub fn relative_link_test() {
  link_target("gemini://fuwn.net/blog/post", "other")
  |> should.equal("/1/blog/other")

  link_target("gemini://fuwn.net", "index2")
  |> should.equal("/1/index2")
}

pub fn directory_link_test() {
  link_target("gemini://fuwn.net", "docs/")
  |> should.equal("/1/docs/")

  link_target("gemini://fuwn.net", "/")
  |> should.equal("/1/")
}

pub fn proxied_capsule_link_test() {
  link_target("gemini://geminiprotocol.net/docs/", "faq.gmi")
  |> should.equal("/1/proxy/geminiprotocol.net/docs/faq.gmi")
}

pub fn external_gemini_link_test() {
  link_target("gemini://fuwn.net", "gemini://geminiprotocol.net/")
  |> should.equal("/1/proxy/geminiprotocol.net/")
}

pub fn gemini_link_query_test() {
  link_target("gemini://fuwn.net", "/search?gleam")
  |> should.equal("/1/search?gleam")
}

pub fn non_gemini_link_test() {
  link_target("gemini://fuwn.net", "https://example.com/a")
  |> should.equal("https://example.com/a")
}
