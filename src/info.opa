@client Info = {{

  draw(g, ctx:Canvas.context) =
    info_height = 2+base_size*grid_heigth
    do Canvas.save(ctx)

    do Canvas.translate(ctx, 2+base_size*grid_width, 0)

    do Canvas.clear_rect(ctx, 0, 0, info_width, info_height)
    do Canvas.set_stroke_style(ctx, {color=Color.black})
    do Canvas.set_line_width(ctx, 2.)
    do Canvas.stroke_rect(ctx, 1, -5,
      info_width+10, info_height+10)

    do Canvas.set_text_align(ctx, {align_center})
    do Canvas.set_font(ctx, "bold 40px Arial")
    cft(t,x,y) =  Canvas.fill_text(ctx, t, x, y)
    do cft("OPAcman", info_width/2, 50)

    do Canvas.set_text_align(ctx, {align_start})
    do Canvas.set_font(ctx, "bold 20px Arial")

    do cft("Lives: {g.lives}", 10, 100)
    do cft("Score: {g.score}", 10, 130)
    do cft("Food left: {Map.size(g.food)}", 10, 160)

    do match g.on_steroids with
      | {none} -> void
      | {some=d} -> cft("Bonus: {1+d/fps}s", 10, 190)

    p = g.pacman.base.pos
    do cft("Player at ({p.x},{p.y})", 10, info_height-10)

    do Canvas.restore(ctx)
    void

  draw_in_center(ctx, text) =
    f = 70
    w=2+base_size*grid_width
    h=2+base_size*grid_heigth
    do Canvas.save(ctx)
    do Canvas.set_text_align(ctx, {align_center})
    do Canvas.set_font(ctx, "bold {f}px Arial")
    do Canvas.fill_text(ctx, text, w/2, (h-f)/2)
    do Canvas.restore(ctx)
    void

  draw_init(t, ctx) =
    text =
      if t < 0 then "Go!"
      else "Starts in {1+t/fps}s"
    draw_in_center(ctx, text)

  draw_game_over(ctx) = draw_in_center(ctx, "GAME OVER")

}}
