@client Wall = {{

  at(x, y, may_teleport) =
    border =
      if may_teleport then
        if x < 0 || x >= grid_width then
          not(List.mem({line=y}, Default.teleports))
        else if y < 0 || y >= grid_heigth then
          not(List.mem({column=x}, Default.teleports))
        else false
      else
        x >= grid_width || y >= grid_heigth || x < 0 || y < 0
    border || Set.mem(~{x y}, Default.walls)

  @private draw_angle(ctx, x, y, angle) =
    w = base_size
    do Canvas.save(ctx)
    do Canvas.set_fill_style(ctx, {color=Color.darkblue})
    do Canvas.translate(ctx, 1+x*w+w/2, 1+y*w+w/2)
    do Canvas.rotate(ctx, angle)
    do Canvas.begin_path(ctx)
    do Canvas.move_to(ctx, w/4, w/2)
    do Canvas.line_to(ctx, -w/4, w/2)
    do Canvas.line_to(ctx, -w/4, w/4)
    do Canvas.arc(ctx, w/4, w/4, w/2, Math.PI, 3.*Math.PI/2., false)
    do Canvas.line_to(ctx, w/2, -w/4)
    do Canvas.line_to(ctx, w/2, w/4)
    do Canvas.arc(ctx, w/2, w/2, w/4, 3.*Math.PI/2., Math.PI, true)
    do Canvas.fill(ctx)
    Canvas.restore(ctx)

  @private draw_line(ctx, x, y, angle) =
    w = base_size
    do Canvas.save(ctx)
    do Canvas.set_fill_style(ctx, {color=Color.darkblue})
    do Canvas.translate(ctx, 1+x*w+w/2, 1+y*w+w/2)
    do Canvas.rotate(ctx, angle)
    do Canvas.fill_rect(ctx, w/2, w/4, -w, -w/2)
    Canvas.restore(ctx)

  @private draw_corner(ctx, x, y, angle) =
    w = base_size
    do Canvas.save(ctx)
    do Canvas.set_fill_style(ctx, {color=Color.darkblue})
    do Canvas.translate(ctx, 1+x*w+w/2, 1+y*w+w/2)
    do Canvas.rotate(ctx, angle)
    do Canvas.begin_path(ctx)
    do Canvas.move_to(ctx, w/4, 0)
    do Canvas.arc(ctx, 0, 0, w/4, 0., Math.PI, true)
    do Canvas.line_to(ctx, -w/4, w/2)
    do Canvas.line_to(ctx, w/4, w/2)
    do Canvas.line_to(ctx, w/4, 0)
    do Canvas.fill(ctx)
    Canvas.restore(ctx)

  @private draw_t(ctx, x, y, angle) =
    w = base_size
    do Canvas.save(ctx)
    do Canvas.set_fill_style(ctx, {color=Color.darkblue})
    do Canvas.translate(ctx, 1+x*w+w/2, 1+y*w+w/2)
    do Canvas.rotate(ctx, angle)
    do Canvas.begin_path(ctx)
    do Canvas.move_to(ctx, w/4, w/2)
    do Canvas.line_to(ctx, -w/4, w/2)
    do Canvas.arc(ctx, -w/2, w/2, w/4, 0., 3.*Math.PI/2., true)
    do Canvas.line_to(ctx, -w/2, -w/4)
    do Canvas.line_to(ctx, w/2, -w/4)
    do Canvas.line_to(ctx, w/2, w/4)
    do Canvas.arc(ctx, w/2, w/2, w/4, 3.*Math.PI/2., Math.PI, true)
    do Canvas.fill(ctx)
    Canvas.restore(ctx)

  @private draw_cross(ctx, x, y) =
    w = base_size
    do Canvas.save(ctx)
    do Canvas.set_fill_style(ctx, {color=Color.darkblue})
    do Canvas.translate(ctx, 1+x*w+w/2, 1+y*w+w/2)
    do Canvas.begin_path(ctx)
    do Canvas.move_to(ctx, w/4, w/2)
    do Canvas.line_to(ctx, -w/4, w/2)
    do Canvas.arc(ctx, -w/2, w/2, w/4, 0., 3.*Math.PI/2., true)
    do Canvas.line_to(ctx, -w/2, -w/4)
    do Canvas.arc(ctx, -w/2, -w/2, w/4, Math.PI/2., 0., true)
    do Canvas.line_to(ctx, w/4, -w/2)
    do Canvas.arc(ctx, w/2, -w/2, w/4, Math.PI, Math.PI/2., true)
    do Canvas.line_to(ctx, w/2, w/4)
    do Canvas.arc(ctx, w/2, w/2, w/4, 3.*Math.PI/2., Math.PI, true)
    do Canvas.fill(ctx)
    Canvas.restore(ctx)

  @private neighbors(x, y) =
    right = at(x+1, y, true)
    left = at(x-1, y, true)
    bottom = at(x, y+1, true)
    top = at(x, y-1, true)
    (top, left, bottom, right)

  draw(ctx:Canvas.context) =
    w = base_size
    do Set.iter(
      ~{x y} ->
        match neighbors(x, y) with
        | ({true}, {false}, {false}, {false}) ->
          draw_corner(ctx, x, y, Math.PI)
        | ({false}, {true}, {false}, {false}) ->
          draw_corner(ctx, x, y, Math.PI/2.)
        | ({false}, {false}, {true}, {false}) ->
          draw_corner(ctx, x, y, 0.)
        | ({false}, {false}, {false}, {true}) ->
          draw_corner(ctx, x, y, 3.*Math.PI/2.)

        | ({true}, {true}, {false}, {false}) ->
          draw_angle(ctx, x, y, Math.PI)
        | ({true}, {false}, {false}, {true}) ->
          draw_angle(ctx, x, y, 3.*Math.PI/2.)
        | ({false}, {true}, {true}, {false}) ->
          draw_angle(ctx, x, y, Math.PI/2.)
        | ({false}, {false}, {true}, {true}) ->
          draw_angle(ctx, x, y, 0.)

        | ({false}, {true}, {true}, {true}) ->
          draw_t(ctx, x, y, 0.)
        | ({true}, {false}, {true}, {true}) ->
          draw_t(ctx, x, y, 3.*Math.PI/2.)
        | ({true}, {true}, {false}, {true}) ->
          draw_t(ctx, x, y, Math.PI)
        | ({true}, {true}, {true}, {false}) ->
          draw_t(ctx, x, y, Math.PI/2.)


        | ({true}, {false}, {true}, {false}) ->
          draw_line(ctx, x, y, Math.PI/2.)
        | ({false}, {true}, {false}, {true}) ->
          draw_line(ctx, x, y, 0.)

        | ({true}, {true}, {true}, {true}) ->
          draw_cross(ctx, x, y)
        | _ ->
          do Canvas.save(ctx)
          do Canvas.set_fill_style(ctx, {color=Color.darkblue})
          do Canvas.fill_rect(ctx, 1+x*w, 1+y*w, w, w)
          Canvas.restore(ctx),
      Default.walls)
    void

}}
