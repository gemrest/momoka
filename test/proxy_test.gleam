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
