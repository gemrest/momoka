import gemtext/gemtext
import gemtext/parse
import gleeunit/should

pub fn link_with_title_test() {
  parse.parse_gemtext_line(
    "=> https://example.com/ This is a link with a title.",
  )
  |> should.equal(gemtext.Link(
    "https://example.com/",
    "This is a link with a title.",
  ))
}

pub fn link_without_title_test() {
  parse.parse_gemtext_line("=> https://example.com/")
  |> should.equal(gemtext.Link("https://example.com/", "https://example.com/"))
}

pub fn link_with_irregular_whitespace_test() {
  parse.parse_gemtext_line("=>https://example.com/ \t Title")
  |> should.equal(gemtext.Link("https://example.com/", "Title"))
}

pub fn quote_test() {
  parse.parse_gemtext_line("> This is a quote.")
  |> should.equal(gemtext.Quote("This is a quote."))
}

pub fn quote_without_space_test() {
  parse.parse_gemtext_line(">This is a quote.")
  |> should.equal(gemtext.Quote("This is a quote."))
}

pub fn list_item_test() {
  parse.parse_gemtext_line("* This is a list item.")
  |> should.equal(gemtext.ListItem("This is a list item."))
}

pub fn heading_test() {
  parse.parse_gemtext_line("# This is a level one heading.")
  |> should.equal(gemtext.Heading("This is a level one heading.", 1))

  parse.parse_gemtext_line("## This is a level two heading.")
  |> should.equal(gemtext.Heading("This is a level two heading.", 2))

  parse.parse_gemtext_line("### This is a level three heading.")
  |> should.equal(gemtext.Heading("This is a level three heading.", 3))
}

pub fn heading_keeps_inner_hashes_test() {
  parse.parse_gemtext_line("# C# Tips")
  |> should.equal(gemtext.Heading("C# Tips", 1))
}

pub fn preformatted_block_test() {
  parse.parse_gemtext(
    "```python\n=> /not-a-link\n# Not a heading\n```\nAfter\n",
  )
  |> should.equal([
    gemtext.Preformatted(["=> /not-a-link", "# Not a heading"]),
    gemtext.Text("After"),
  ])
}

pub fn unterminated_preformatted_block_test() {
  parse.parse_gemtext("```\ncode")
  |> should.equal([gemtext.Preformatted(["code"])])
}

pub fn crlf_document_test() {
  parse.parse_gemtext("Hello\r\n```\r\ncode\r\n```\r\n")
  |> should.equal([gemtext.Text("Hello"), gemtext.Preformatted(["code"])])
}

pub fn blank_lines_test() {
  parse.parse_gemtext("One\n\nTwo\n")
  |> should.equal([gemtext.Text("One"), gemtext.Text(""), gemtext.Text("Two")])
}
