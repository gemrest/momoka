import gemtext/parse
import gleeunit/should
import gopher

fn render(text: String) -> String {
  text
  |> parse.parse_gemtext
  |> gopher.gemtext_to_gopher
}

pub fn document_test() {
  render("# Title\n\nHello\n* Item\n> Quote\n")
  |> should.equal(
    "i# Title\t\tnull.host\t1\r\n"
    <> "i\t\tnull.host\t1\r\n"
    <> "iHello\t\tnull.host\t1\r\n"
    <> "i* Item\t\tnull.host\t1\r\n"
    <> "i> Quote\t\tnull.host\t1\r\n"
    <> ".\r\n",
  )
}

pub fn document_without_trailing_newline_test() {
  render("Hello")
  |> should.equal("iHello\t\tnull.host\t1\r\n.\r\n")
}

pub fn empty_document_test() {
  render("")
  |> should.equal(".\r\n")
}

pub fn preformatted_block_test() {
  render("```\nfirst\n=> second\n```\n")
  |> should.equal(
    "i`` first\t\tnull.host\t1\r\n"
    <> "i`` => second\t\tnull.host\t1\r\n"
    <> ".\r\n",
  )
}

pub fn tab_in_text_test() {
  render("a\tb\n")
  |> should.equal("ia    b\t\tnull.host\t1\r\n.\r\n")
}

pub fn absolute_link_test() {
  render("=> https://example.com/a/b/c Deep\n")
  |> should.equal(
    "hDeep\tURL:https://example.com/a/b/c\texample.com\t70\r\n.\r\n",
  )
}

pub fn local_link_test() {
  render("=> /index2\n")
  |> should.equal("h/index2\tURL:/index2\tnull.host\t70\r\n.\r\n")
}

pub fn error_menu_test() {
  gopher.error_menu("Oops.")
  |> should.equal("iAn error has occurred: Oops.\t\tnull.host\t1\r\n.\r\n")
}
