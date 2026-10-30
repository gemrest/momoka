import gemtext
import gleeunit/should

pub fn link_with_title_test() {
  gemtext.parse("=> https://example.com/ This is a link with a title.")
  |> should.equal([
    gemtext.Link("https://example.com/", "This is a link with a title."),
  ])
}

pub fn link_without_title_test() {
  gemtext.parse("=> https://example.com/")
  |> should.equal([gemtext.Link("https://example.com/", "https://example.com/")])
}

pub fn link_with_irregular_whitespace_test() {
  gemtext.parse("=>https://example.com/ \t Title")
  |> should.equal([gemtext.Link("https://example.com/", "Title")])
}

pub fn quote_test() {
  gemtext.parse("> This is a quote.")
  |> should.equal([gemtext.Quote("This is a quote.")])
}

pub fn quote_without_space_test() {
  gemtext.parse(">This is a quote.")
  |> should.equal([gemtext.Quote("This is a quote.")])
}

pub fn list_item_test() {
  gemtext.parse("* This is a list item.")
  |> should.equal([gemtext.ListItem("This is a list item.")])
}

pub fn heading_test() {
  gemtext.parse("# This is a level one heading.")
  |> should.equal([gemtext.Heading("This is a level one heading.", 1)])

  gemtext.parse("## This is a level two heading.")
  |> should.equal([gemtext.Heading("This is a level two heading.", 2)])

  gemtext.parse("### This is a level three heading.")
  |> should.equal([gemtext.Heading("This is a level three heading.", 3)])
}

pub fn heading_keeps_inner_hashes_test() {
  gemtext.parse("# C# Tips")
  |> should.equal([gemtext.Heading("C# Tips", 1)])
}

pub fn preformatted_block_test() {
  gemtext.parse("```python\n=> /not-a-link\n# Not a heading\n```\nAfter\n")
  |> should.equal([
    gemtext.Preformatted(["=> /not-a-link", "# Not a heading"]),
    gemtext.Text("After"),
  ])
}

pub fn unterminated_preformatted_block_test() {
  gemtext.parse("```\ncode")
  |> should.equal([gemtext.Preformatted(["code"])])
}

pub fn crlf_document_test() {
  gemtext.parse("Hello\r\n```\r\ncode\r\n```\r\n")
  |> should.equal([gemtext.Text("Hello"), gemtext.Preformatted(["code"])])
}

pub fn blank_lines_test() {
  gemtext.parse("One\n\nTwo\n")
  |> should.equal([gemtext.Text("One"), gemtext.Text(""), gemtext.Text("Two")])
}
