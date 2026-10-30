import gleam/option.{type Option}

pub type Gemtext {
  Text(String)
  Link(to: String, title: Option(String))
  Heading(String, depth: Int)
  ListLine(String)
  BlockquoteLine(String)
  PreformattedLine(String)
  Whitespace
}
