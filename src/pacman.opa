@client Pacman = {{

  @server default = {
    base = Base.make(0, 0, {right}, 10)
    next_dir    = {right}
    mouth_state = 0
    mouth_incr  = 1
    mouth_steps = 10
  } : Pacman.t

  draw(ctx:Canvas.context) =
    g = game.get()
    p = g.pacman
    w = base_size

    mouth = p.mouth_state
    dmouth = p.mouth_incr
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

    mouth = mouth + dmouth;
    dmouth =
      if (mouth == steps-1 || mouth == 0) then -dmouth
      else dmouth
    do game.set({g with pacman = {
        p with
          mouth_state = mouth
          mouth_incr = dmouth
      }})
    void

  move() =
    g = game.get()
    p = g.pacman
    ignore_incr = p.base.cur_step < 0
    cur_step = p.base.cur_step + 1
    cur_step = if cur_step >= p.base.max_steps then 0
      else if p.base.dir == {still} then 0
      else cur_step
    test_wall(on_ok, on_err, x, y) =
      if Wall.at(x,y) then on_err
      else on_ok
    (dir, dx, dy) =
      if cur_step != 0 || ignore_incr then (p.base.dir, 0, 0)
      else
        do print_infos(g)
        (dx, dy) = Base.Dir.deltas(p.base.dir)
        (ddx, ddy) = Base.Dir.deltas(p.next_dir)
        dir = test_wall(p.next_dir, {still},
                        p.base.pos.x+dx+ddx, p.base.pos.y+dy+ddy)
        (dx, dy, dir) =
          test_wall((dx,dy,dir), (0,0,{still}),
                    p.base.pos.x+dx, p.base.pos.y+dy)
        (dir, dx, dy)
    pos = {
      x = p.base.pos.x + dx
      y = p.base.pos.y + dy
    }
    (food, score) =
      if cur_step != p.base.max_steps/2 then (g.food, g.score)
      else
        if Set.mem(pos, g.food) then
          food = Set.remove(pos, g.food)
          if food == Set.empty then (initial_food, g.score+1010)
          else (food, g.score+10)
        else (g.food, g.score)
    pacman = {p with base = { p.base with
      ~pos ~dir ~cur_step }}
    game.set({g with ~pacman ~food ~score})

}}
