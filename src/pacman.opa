@client Pacman = {{

  @private draw_one(p:Pacman.t, ctx:Canvas.context) =
    w = base_size

    mouth = p.mouth_step
    steps = p.mouth_steps

    do Canvas.save(ctx)
    do Canvas.set_fill_style(ctx, {color=Color.black})
    (center_x, center_y) = Base.center(p.base)
    do Canvas.translate(ctx, center_x, center_y)
    alpha = Base.Dir.facing_angle(p.base.dir)
    do Canvas.rotate(ctx, alpha)

    angle = Math.PI*Int.to_float((steps-mouth)/(3*steps))
    x = Int.of_float(Float.of_int(w)*Math.cos(angle)/2.)-1
    y = (w*(steps-mouth))/(4*steps)

    do Canvas.begin_path(ctx)
    do Canvas.move_to(ctx, -w/10, 0)
    // Could replace all curves but currently not available in OPA :(
    // do Canvas.arc(0, 0, w/2, -angle, angle, 1)
    do Canvas.line_to(ctx, x, y)
    do Canvas.quadratic_curve_to(ctx, w/2, w/2, 0, w/2)
    do Canvas.quadratic_curve_to(ctx, -w/2, w/2, -w/2, 0)
    do Canvas.quadratic_curve_to(ctx, -w/2, -w/2, 0, -w/2)
    do Canvas.quadratic_curve_to(ctx, w/2, -w/2, x, -y)
    do Canvas.fill(ctx)
    do Canvas.restore(ctx)
    void

  @private draw_clones(f:Base.pos->Base.pos, p1:Pacman.t, ctx:Canvas.context) =
    p2 = {p1 with base={p1.base with pos=f(p1.base.pos)}}
    do draw_one(p1, ctx)
    do draw_one(p2, ctx)
    void

  draw(g, ctx:Canvas.context) =
    p = g.pacman
    if (p.base.dir == {left} || p.base.dir == {right})
         && p.base.pos.x == 0 then
      draw_clones({x=_ ~y} -> {x=grid_width ~y}, p, ctx)
    else if (p.base.dir == {left} || p.base.dir == {right})
         && p.base.pos.x == grid_width-1 then 
      draw_clones({x=_ ~y} -> {x=-1 ~y}, p, ctx)
    else if (p.base.dir == {up} || p.base.dir == {down})
         && p.base.pos.y == 0 then 
      draw_clones({~x y=_} -> {~x y=grid_heigth}, p, ctx)
    else if (p.base.dir == {up} || p.base.dir == {down})
         && p.base.pos.y == grid_heigth-1 then 
      draw_clones({~x y=_} -> {~x y=-1}, p, ctx)
    else draw_one(p, ctx)

  move(g) =
    p = g.pacman
    ignore_incr = p.base.cur_step < 0
    cur_step = p.base.cur_step + 1
    cur_step = if cur_step >= p.base.max_steps then 0
      else if Base.Dir.is_still(p.base.dir) then 0
      else cur_step
    test_wall(on_ok, on_err, x, y) =
      if Wall.at(x,y, true) then on_err
      else on_ok
    (dir, dx, dy) =
      if cur_step != 0 then (p.base.dir, 0, 0)
      else
        do print_infos(g)
        (dx, dy) = Base.Dir.deltas(p.base.dir)
        (ddx, ddy) = Base.Dir.deltas(p.next_dir)
        dir = test_wall(p.next_dir, Base.Dir.get_still(p.next_dir),
                        p.base.pos.x+dx+ddx, p.base.pos.y+dy+ddy)
        (dx, dy, dir) =
          test_wall((dx,dy,dir), (0,0,Base.Dir.get_still(dir)),
                    p.base.pos.x+dx, p.base.pos.y+dy)
        if ignore_incr then (dir, 0, 0)
        else (dir, dx, dy)
    pos = {
      x = mod(grid_width + p.base.pos.x + dx, grid_width)
      y = mod(grid_heigth + p.base.pos.y + dy, grid_heigth)
    }

    (food, dscore, steroids) =
      if cur_step != p.base.max_steps/2 then (g.food, 0, g.on_steroids)
      else Food.check(pos, g.food, g.on_steroids)
    score = g.score + dscore
    on_steroids = match steroids with
      | {none} -> none
      | {some=t} ->
        if t < 1 then none
        else some(t-1)
    mouth = p.mouth_step + p.mouth_incr
    dmouth =
      if (mouth == p.mouth_steps-1 || mouth == 0) then -p.mouth_incr
      else p.mouth_incr
    pacman =
      { p with
            mouth_step = mouth
            mouth_incr = dmouth
            base = { p.base with ~pos ~dir ~cur_step } }
    {g with ~pacman ~food ~score ~on_steroids}

}}
