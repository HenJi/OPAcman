@client Food = {{

  draw(ctx:Canvas.context) =
    food = game.get().food
    w = base_size
    do Canvas.save(ctx)
    do Canvas.set_fill_style(ctx, {color=Color.red})
    do Set.iter(
      ~{x y} -> Canvas.fill_rect(ctx, w/2+x*w-2, w/2+y*w-2, 6, 6),
      food)
    do Canvas.restore(ctx)
    void

}}
