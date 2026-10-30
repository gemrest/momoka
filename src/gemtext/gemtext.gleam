pub type Gemtext {
  Text(String)
  Link(to: String, title: String)
  Heading(String, depth: Int)
  ListItem(String)
  Quote(String)
  Preformatted(lines: List(String))
}
