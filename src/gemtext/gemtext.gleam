import gleam/option.{type Option}

pub type Gemtext {
  Text(String)
  Link(to: String, Option(String))
  Heading(String, depth: Int)
  ListLine(String)
  List(List(List(String)))
  BlockquoteLine(String)
  Blockquote(String)
  Preformatted(description: Option(String), body: String)
  PreformattedLine(String)
  Whitespace
}
