@client Food = {{

  check(pos, food) =
    match Map.extract(pos, food) with
    | (food, {none}) -> (food, 0)
    | (food, {some=f}) ->
      score = match f with
        | {normal} -> 10
        | {steroids} -> 100
      if food == Map.empty then (Default.food, score+1000)
      else (food, score)

  draw(g, ctx:Canvas.context) =
    food = g.food
    w = base_size
    do Canvas.save(ctx)
    do Canvas.set_fill_style(ctx, {color=Color.red})
    do Map.iter(
      ~{x y}, t ->
        match t with
        | {normal} ->
          Canvas.fill_rect(ctx, w/2+x*w-2, w/2+y*w-2, 6, 6)
        | {steroids} ->
          Canvas.fill_rect(ctx, w/2+x*w-5, w/2+y*w-5, 11, 11),
      food)
    do Canvas.restore(ctx)
    void

}}
