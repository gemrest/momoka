import gemtext/gemtext
import gemtext/parse
import gleam/option.{None, Some}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn parse_gemtext_link_with_title_test() {
  parse.parse_gemtext_line(
    "=> https://example.com/ This is a link with a title.",
  )
  |> should.equal(gemtext.Link(
    "https://example.com/",
    Some("This is a link with a title."),
  ))
}

pub fn parse_gemtext_link_without_title_test() {
  parse.parse_gemtext_line("=> https://example.com/")
  |> should.equal(gemtext.Link("https://example.com/", None))
}

pub fn parse_gemtext_blockquote_line_test() {
  parse.parse_gemtext_line("> This is a quote.")
  |> should.equal(gemtext.BlockquoteLine("This is a quote."))
}

pub fn parse_gemtext_list_line_test() {
  parse.parse_gemtext_line("* This is a list item.")
  |> should.equal(gemtext.ListLine("This is a list item."))
}

pub fn parse_gemtext_whitespace_line_test() {
  parse.parse_gemtext_line("")
  |> should.equal(gemtext.Whitespace)
}

pub fn parse_gemtext_heading_level_one_test() {
  parse.parse_gemtext_line("# This is a level one heading.")
  |> should.equal(gemtext.Heading("This is a level one heading.", 1))
}

pub fn parse_gemtext_heading_level_two_test() {
  parse.parse_gemtext_line("## This is a level two heading.")
  |> should.equal(gemtext.Heading("This is a level two heading.", 2))
}

pub fn parse_gemtext_heading_level_three_test() {
  parse.parse_gemtext_line("### This is a level three heading.")
  |> should.equal(gemtext.Heading("This is a level three heading.", 3))
}

pub fn parse_gemtext_preformatted_line_test() {
  parse.parse_gemtext_line("```")
  |> should.equal(gemtext.PreformattedLine("```\n"))
}

pub fn parse_gemtext_preformatted_flattened_block_test() {
  parse.parse_gemtext_line("```\nThis is a preformatted block.\n```")
  |> should.equal(gemtext.PreformattedLine(
    "```\n\nThis is a preformatted block.\n```",
  ))
}
