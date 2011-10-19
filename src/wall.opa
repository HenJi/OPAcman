@client Wall = {{

  draw(ctx:Canvas.context) =
    w = base_size
    do Canvas.save(ctx)
    do Canvas.set_fill_style(ctx, {color=Color.darkblue})
    do Set.iter(
      ~{x y} -> Canvas.fill_rect(ctx, 1+x*w, 1+y*w, w, w),
      walls)
    do Canvas.restore(ctx)
    void

  at(x, y) =
    x >= grid_width || y >= grid_heigth
    || x < 0 || y < 0
    || Set.mem(~{x y}, walls)

}}
