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
      | {some=d} -> cft("Bonus: {1+d/60}", 10, 190)

    p = g.pacman.base.pos
    do cft("Player at ({p.x},{p.y})", 10, info_height-10)

    do Canvas.restore(ctx)
    void

}}
