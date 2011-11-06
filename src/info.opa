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
    do Canvas.fill_text(ctx, "OPAcman", info_width/2, 50)

    do Canvas.set_text_align(ctx, {align_start})
    do Canvas.set_font(ctx, "bold 20px Arial")
    do Canvas.translate(ctx, 10, 70)

    cft(t,dy) =
      do Canvas.translate(ctx, 0, dy)
      Canvas.fill_text(ctx, t, 0, 0)

    do cft("Lives: {g.lives}", 30)
    do cft("Score: {g.score}", 30)
    do cft("Food left: {Map.size(g.food)}", 30)

    do if g.state == {game_over} then
      cft("'r': restart", 30)

    do match g.on_steroids with
      | {none} -> void
      | {some=s} -> cft("Bonus: {1+s.cycles/fps}s", 30)

    do Canvas.restore(ctx)

    do Canvas.save(ctx)
    do Canvas.set_font(ctx, "bold 20px Arial")
    do Canvas.translate(ctx, 2+base_size*grid_width, 0)
    p = g.pacman.base.pos
    do Canvas.fill_text(ctx,
      "Move with", 10, info_height-100)
    do Canvas.fill_text(ctx,
      "'wasd' or 'zqsd'", 10, info_height-70)
    do Canvas.fill_text(ctx,
      "'space': pause", 10, info_height-40)
    do Canvas.fill_text(ctx,
      "Player at ({p.x},{p.y})", 10, info_height-10)
    do Canvas.restore(ctx)

    void

  draw_in_center(ctx, text, caption) =
    f = 70
    w=2+base_size*grid_width
    h=2+base_size*grid_heigth
    do Canvas.save(ctx)

    do Canvas.set_text_align(ctx, {align_center})
    do Canvas.set_font(ctx, "bold {f}px Arial")
    do Canvas.fill_text(ctx, text, w/2, (h-f)/2)

    do match caption with
      | {none} -> void
      | {some=t} ->
        do Canvas.set_font(ctx, "bold {f/2}px Arial")
        do Canvas.fill_text(ctx, t, w/2, h/2)
        void

    do Canvas.restore(ctx)
    void

  draw_init(ctx) =
    draw_in_center(ctx, "OPAcman", some("Move in any direction to start"))

  draw_game_over(ctx) =
    draw_in_center(ctx, "GAME OVER", some("'r' to restart"))

  draw_pause(ctx) =
    draw_in_center(ctx, "PAUSE", some("'space' or any direction to resume"))


}}
