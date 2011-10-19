@client Ghost = {{

  draw_one(ctx:Canvas.context, g:Ghost.t) =
    w = base_size

    do Canvas.save(ctx)
    do Canvas.set_fill_style(ctx, {color=g.color})
    (center_x, center_y) = Base.center(g.base)
    do Canvas.translate(ctx, center_x, center_y)

    do Canvas.begin_path(ctx)
    do Canvas.move_to(ctx, w/2, 0)
    do Canvas.quadratic_curve_to(ctx, w/2, -w/2, 0, -w/2)
    do Canvas.quadratic_curve_to(ctx, -w/2, -w/2, -w/2, 0)
    do Canvas.line_to(ctx, -w/2, w/2)
    do Canvas.line_to(ctx, -w/6, w/3)
    do Canvas.line_to(ctx, 0, w/2)
    do Canvas.line_to(ctx, w/6, w/3)
    do Canvas.line_to(ctx, w/2, w/2)
    do Canvas.fill(ctx)

    do Canvas.clear_rect(ctx, -w/4, -w/4, w/2, w/4)
    do Canvas.set_fill_style(ctx, {color=(g.eye_color)})
    dx =
      base = g.eye_steps
      step =
        if g.eye_step > base/2 then base - g.eye_step
        else g.eye_step
      (w*step)/(2*base)
    do Canvas.fill_rect(ctx, dx-w/4, -w/4, w/4, w/4)

    do Canvas.restore(ctx)
    void

  @private build_move_options(b:Base.t, no_back) =
    all_options = [] : list(Base.direction)
      |> (if Wall.at(b.pos.x+1, b.pos.y) then identity
          else List.add({right}, _))
      |> (if Wall.at(b.pos.x-1, b.pos.y) then identity
          else List.add({left}, _))
      |> (if Wall.at(b.pos.x, b.pos.y+1) then identity
          else List.add({down}, _))
      |> (if Wall.at(b.pos.x, b.pos.y-1) then identity
          else List.add({up}, _))
    if List.length(all_options) == 1 then all_options
    else if no_back then
      back = Base.Dir.back(b.dir)
      List.filter(x -> x!=back, all_options)
    else all_options

  @private move_one_generic(g:Ghost.t, move_fun) =
    cur_step = g.base.cur_step + 1
    cur_step =
      if cur_step >= g.base.max_steps then 0
      else cur_step
    g = {g with eye_step = mod(g.eye_step+1, g.eye_steps)}
    if cur_step != 0 then {g with base = {g.base with ~cur_step}}
    else
      (dx, dy) = Base.Dir.deltas(g.base.dir)
      pos = {
	x = g.base.pos.x + dx
	y = g.base.pos.y + dy
      }
      g = {g with base = {g.base with ~pos}}
      dirs = move_fun(g.base)
      dir = List.get(Random.int(List.length(dirs)), dirs) ? {down}
      {g with base = {g.base with ~dir ~cur_step} }

  @private move_one_dumb(ghost:Ghost.t) =
    move_one_generic(ghost, build_move_options(_, true))

  @private move_one_guard(ghost:Ghost.t, bp:Base.t) =
    move_fun(bg) =
      opts = build_move_options(bg, false)
      can_see(dir) =
        if bg.pos.x != bp.pos.x && bg.pos.y != bp.pos.y then false
        else if bg.pos.x == bp.pos.x && bg.pos.y > bp.pos.y
                && dir == {up} then true
        else if bg.pos.x == bp.pos.x && bg.pos.y < bp.pos.y
                && dir == {down} then true
        else if bg.pos.y == bp.pos.y && bg.pos.x > bp.pos.x
                && dir == {left} then true
        else if bg.pos.y == bp.pos.y && bg.pos.x < bp.pos.x
                && dir == {right} then true
        else false
      bias = List.filter(can_see, opts)
      if bias == [] then
        if List.length(opts) == 1 then opts
        else
          back = Base.Dir.back(bg.dir)
          List.filter(x -> x!=back, opts)
      else bias
    move_one_generic(ghost, move_fun)

  move(g) =
    ghosts = List.map(
      ghost -> match ghost.ai with
        | {dumb} -> move_one_dumb(ghost)
        | {guard} -> move_one_guard(ghost, g.pacman.base),
      g.ghosts)
    {g with ~ghosts}

  draw(g, ctx:Canvas.context) =
    List.iter(draw_one(ctx, _), g.ghosts)

}}
