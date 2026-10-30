import gemini
import gleeunit/should

pub fn success_test() {
  gemini.parse_response("20 text/gemini; lang=en\r\n# Hello\n")
  |> should.equal(Ok(gemini.Success("text/gemini; lang=en", "# Hello\n")))
}

pub fn success_without_mime_type_test() {
  gemini.parse_response("20\r\nHello")
  |> should.equal(Ok(gemini.Success("", "Hello")))
}

pub fn input_test() {
  gemini.parse_response("10 Enter search query\r\n")
  |> should.equal(Ok(gemini.Input("Enter search query")))
}

pub fn redirect_test() {
  gemini.parse_response("31 gemini://example.com/docs/\r\n")
  |> should.equal(Ok(gemini.Redirect("gemini://example.com/docs/")))
}

pub fn failure_test() {
  gemini.parse_response("51 Not found\r\n")
  |> should.equal(Ok(gemini.Failure(51, "Not found")))
}

pub fn malformed_test() {
  gemini.parse_response("hello")
  |> should.equal(Error("The capsule's response is malformed."))

  gemini.parse_response("OK fine\r\n")
  |> should.equal(Error("The capsule's response is malformed."))
}
