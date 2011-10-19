/* Config */

fps = 60
base_size = 32
grid_width  = List.length(List.head(grid))
grid_heigth = List.length(grid)

/* Defaults */

default_game = {
  pacman = Default.pacman
  ghosts = Default.ghosts
  food   = Default.food
  score  = 0
} : Game.status

/* Game */

@client game = Mutable.make(default_game)

@client draw_grid(ctx:Canvas.context) =
  w = base_size
  do Canvas.save(ctx)
  do Canvas.set_stroke_style(ctx, {color=Color.pink})
  do Canvas.set_line_width(ctx, 1.)
  do Canvas.begin_path(ctx)
  // lh = List.init(identity, grid_heigth)
  do List.iter(
    x ->
      do Canvas.move_to(ctx, x*w, 1)
      do Canvas.line_to(ctx, x*w, 1+w*grid_heigth)
      void,
    List.init(x->x+1, grid_width-1))
  do List.iter(
    y ->
      do Canvas.move_to(ctx, 1, y*w)
      do Canvas.line_to(ctx, 1+w*grid_width, y*w)
      void,
    List.init(y->y+1, grid_heigth-1))
  do Canvas.stroke(ctx)
  do Canvas.restore(ctx)
  void

@client clean_frame(ctx:Canvas.context) =
  Canvas.clear_rect(
    ctx, 0, 0,
    2+2*base_size*grid_width,
    2+2*base_size*grid_heigth)

@client print_infos(g:Game.status) =
  p = g.pacman
  cont =
    <>
      Pacman at ({p.base.pos.x},{p.base.pos.y}), moving {"{p.base.dir}"}
      - {Map.size(g.food)} food left
      - Score: {g.score}
    </>
  Dom.transform([#info <- cont])

@client next_frame(ctx:Canvas.context)() =
  g = game.get()
   |> Pacman.move
   |> Ghost.move
  do clean_frame(ctx)
  do Wall.draw(ctx)
  do Food.draw(g, ctx)
  do Pacman.draw(g, ctx)
  do Ghost.draw(g, ctx)
  game.set(g)

@client keyfun(e) =
  g = game.get()
  p = g.pacman
  p = match (p.base.dir, e.key_code) with
    // z
    | ({down}, {some=122}) ->
        {p with next_dir={up}
                base={p.base with dir={up}
                                  cur_step=-p.base.cur_step}}
    | (_, {some=122}) -> {p with next_dir={up}}

    // q
    | ({right}, {some=113}) ->
        {p with next_dir={left}
                base={p.base with dir={left}
                                  cur_step=-p.base.cur_step}}
    | (_, {some=113}) -> {p with next_dir={left}}

    // s
    | ({up}, {some=115}) ->
        {p with next_dir={down}
                base={p.base with dir={down}
                                  cur_step=-p.base.cur_step}}
    | (_, {some=115}) -> {p with next_dir={down}}

    // d
    | ({left}, {some=100}) ->
        {p with next_dir={right}
                base={p.base with dir={right}
                                  cur_step=-p.base.cur_step}}
    | (_, {some=100}) -> {p with next_dir={right}}

    // space (pause)
    | (_, {some=32}) -> {p with next_dir=Base.Dir.get_still(p.base.dir)}
    | _ -> p
  game.set({g with pacman=p})

@client init() =
  match Canvas.get(#game_holder) with
  | {none} -> void
  | {some=canvas} ->
    ctx = Canvas.get_context_2d(canvas) |> Option.get
    t = Scheduler.make_timer(1000/fps, next_frame(ctx))
    _ = Dom.bind(Dom.select_document(), {keypress}, keyfun)
    t.start()

body() =
  <>
    <canvas id="game_holder"
            width="{2+base_size*grid_width}"
            height="{2+base_size*grid_heigth}">
      You can't see canvas, upgrade your browser !
    </canvas>
    <div>
      <span id="info" onready={_ -> init()}></span>
    </div>
  </>

server = one_page_server("OPAcman", body)

css = css
  canvas { border: 1px solid black; }
