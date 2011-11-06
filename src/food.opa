@client Food = {{

  check(pos, food, cur_steroids) =
    speed =
      if Option.is_none(cur_steroids) then pacman_speed
      else pacman_speed_on_steroids
    match Map.extract(pos, food) with
    | (food, {none}) -> (food, 0, cur_steroids, speed)
    | (food, {some=f}) ->
      (food, d) =
        if food == Map.empty then (Default.food, clear_bonus)
        else (food, 0)
      match f with
      | {normal} -> (food, food_points+d, cur_steroids, speed)
      | {steroids} ->
        new_steroids = match cur_steroids with
          | {none} ->
            {cycles = steroid_len
             combo = 0}
          | {some=s} ->
            {cycles = s.cycles+steroid_len
             combo = s.combo}
        (food, steroid_points+d,
         some(new_steroids), pacman_speed_on_steroids)

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
          blink(
           -> Canvas.fill_rect(ctx, w/2+x*w-5, w/2+y*w-5, 11, 11)
          ),
      food)
    do Canvas.restore(ctx)
    void

}}
