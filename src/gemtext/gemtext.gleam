import gleam/option.{type Option}

pub type Gemtext {
  Text(String)
  Link(to: String, title: Option(String))
  Heading(String, depth: Int)
  ListItem(String)
  Quote(String)
  Preformatted(lines: List(String))
}
