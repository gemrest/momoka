import gemtext/gemtext.{type Gemtext}
import gleam/list

pub fn group_adjacent_list_items(lines: List(Gemtext)) -> List(Gemtext) {
  case lines {
    [gemtext.ListLine(a), gemtext.ListLine(b), ..rest] ->
      group_adjacent_list_items([gemtext.List([[a], [b]]), ..rest])
    [gemtext.List(lists), gemtext.ListLine(item), ..rest] ->
      group_adjacent_list_items([
        gemtext.List(list.append(lists, [[item]])),
        ..rest
      ])
    [g, ..rest] -> list.append([g], group_adjacent_list_items(rest))
    [] -> []
  }
}
