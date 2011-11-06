database ./opacman

db /opacman/scores: list((int, string))

@server @publish Scores = {{

  get() =
    /opacman/scores

  add(name, value) =
    nl = String.length(name)
    name =
      if nl == 0 then "ZZZ"
      else if nl > 3 then String.substring_unsafe(0, 3, name)
      else name
    cur = /opacman/scores
    scores = [(value, name)|cur]
      |> List.sort_by(_.f1, _)
      |> List.rev
      |> List.split_at(_, 5)
      |> _.f1
    do /opacman/scores <- scores
    scores

}}

_ = if /opacman/scores == [] then
  _ = Scores.add("AAA", 10000)
  _ = Scores.add("BBB", 7500)
  _ = Scores.add("CCC", 5000)
  _ = Scores.add("DDD", 2500)
  _ = Scores.add("EEE", 0)
  void
