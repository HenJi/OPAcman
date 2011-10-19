@client Wall = {{

  draw(ctx:Canvas.context) =
    w = base_size
    do Canvas.save(ctx)
    do Canvas.set_fill_style(ctx, {color=Color.darkblue})
    do Set.iter(
      ~{x y} -> Canvas.fill_rect(ctx, 1+x*w, 1+y*w, w, w),
      Default.walls)
    do Canvas.restore(ctx)
    void

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

}}
