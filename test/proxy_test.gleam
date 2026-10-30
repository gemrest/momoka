import gleeunit/should
import proxy

const config =
  proxy.Config(root_capsule: "fuwn.me", gemini_proxy: "https://fuwn.me/raw/")

pub fn root_selector_test() {
  proxy.capsule_location(config, "")
  |> should.equal(Ok("fuwn.me"))
}

pub fn root_capsule_path_test() {
  proxy.capsule_location(config, "/index2")
  |> should.equal(Ok("fuwn.me/index2"))
}

pub fn proxied_capsule_test() {
  proxy.capsule_location(config, "/proxy/geminiprotocol.net/docs")
  |> should.equal(Ok("geminiprotocol.net/docs"))
}

pub fn unsupported_selector_test() {
  proxy.capsule_location(config, "index2")
  |> should.equal(Error(Nil))
}

pub fn absolute_root_capsule_link_test() {
  proxy.link_target(config, "fuwn.me", "/index2")
  |> should.equal("/1/index2")
}

pub fn relative_link_test() {
  proxy.link_target(config, "fuwn.me/blog/post", "other")
  |> should.equal("/1/blog/other")

  proxy.link_target(config, "fuwn.me", "index2")
  |> should.equal("/1/index2")
}

pub fn directory_link_test() {
  proxy.link_target(config, "fuwn.me", "docs/")
  |> should.equal("/1/docs/")

  proxy.link_target(config, "fuwn.me", "/")
  |> should.equal("/1/")
}

pub fn proxied_capsule_link_test() {
  proxy.link_target(config, "geminiprotocol.net/docs/", "faq.gmi")
  |> should.equal("/1/proxy/geminiprotocol.net/docs/faq.gmi")
}

pub fn external_gemini_link_test() {
  proxy.link_target(config, "fuwn.me", "gemini://geminiprotocol.net/")
  |> should.equal("/1/proxy/geminiprotocol.net/")
}

pub fn gemini_link_query_test() {
  proxy.link_target(config, "fuwn.me", "/search?gleam")
  |> should.equal("/1/search?gleam")
}

pub fn non_gemini_link_test() {
  proxy.link_target(config, "fuwn.me", "https://example.com/a")
  |> should.equal("https://example.com/a")
}
