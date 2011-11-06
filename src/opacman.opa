import stdlib.web.canvas

/* Config */

fps = 60
base_size = 32
grid_width  = List.length(List.head(grid))
grid_heigth = List.length(grid)
info_width = 200

food_points = 10
steroid_points = 100
steroid_len = 5*fps /* frames */
clear_bonus = 500
life_points = 2500


/* Defaults */

default_game = {
  state       = {game_start}
  pacman      = Default.pacman
  ghosts      = Default.ghosts
  food        = Default.food
  score       = 0
  lives       = 3
  on_steroids = none
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

check_collision(g) =
  pc = Base.center(g.pacman.base)
  has_collision = List.fold(
    ghost, res ->
      if res then res
      else
        gc = Base.center(ghost.base)
        x = gc.f1 - pc.f1
        y = gc.f2 - pc.f2
        d = Math.sqrt_i(x*x+y*y)
        d < base_size,
    g.ghosts, false)
  if has_collision && g.lives == 1 then
    {g with
      state = {game_over}
      lives = 0}
  else if has_collision then
    {default_game with
      food = g.food
      score = g.score
      lives = g.lives-1}
  else g

@client clean_frame(ctx:Canvas.context) =
  Canvas.clear_rect(
    ctx, 0, 0,
    2+base_size*grid_width,
    2+base_size*grid_heigth)

@client blink(f) =
  t = Date.now() |> Date.in_milliseconds
  t = t / 100
  t = t - (t/10)*10
  if t > 5 then f()

@client next_frame(ctx:Canvas.context)() =
  draw_board(g) =
    do clean_frame(ctx)
    do Wall.draw(ctx)
    do Food.draw(g, ctx)
    do Pacman.draw(g, ctx)
    do Ghost.draw(g, ctx)
    do Info.draw(g, ctx)
    void
  g = game.get()
  do draw_board(g)
  g = match g.state with
    | {game_over} ->
      do blink(->Info.draw_game_over(ctx))
      g
    | {pause} ->
      do blink(->Info.draw_pause(ctx))
      g
    | {game_start} ->
      do blink(->Info.draw_init(ctx))
      {g with state={game_start}}
    | {running} ->
      Pacman.move(g)
      |> Ghost.move
      |> check_collision
  game.set(g)

@client keyfun(e) =
  g = game.get()
  p = g.pacman
  do Dom.transform([#debug <- "{e.key_code}"])
  p = match (p.base.dir, e.key_code) with
    // z + w
    | ({down}, {some=122}) | ({down}, {some=119}) ->
        {p with next_dir={up}
                base={p.base with dir={up}
                                  cur_step=-p.base.cur_step}}
    | (_, {some=122}) -> {p with next_dir={up}}

    // q + a
    | ({right}, {some=113}) | ({right}, {some=97}) ->
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

    | _ -> p
  directions = [122, 119, 113, 97, 115, 100]
  g = match (g.state, e.key_code) with
    // r (reset if game over)
    | ({game_over}, {some=114}) -> default_game

    // space (pause start)
    | ({running}, {some=32}) -> {g with state={pause}}

    // any direction or space to resume
    | ({pause}, {some=k}) ->
      if k == 32 || List.mem(k, directions) then
        {g with state={running} pacman=p}
      else g

    // any direction to start game
    | ({game_start}, {some=k}) ->
      if List.mem(k, directions) then
        {g with state={running} pacman=p}
      else g

    | _ -> {g with pacman=p}
  game.set(g)

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
            width="{2+base_size*grid_width+info_width}"
            height="{2+base_size*grid_heigth}">
      You can't see canvas, upgrade your browser !
    </canvas>
    <div>
      <span id="info" onready={_ -> init()}></span>
      <span id="debug"></span>
    </div>
  </>

server = one_page_server("OPAcman", body)

css = css
  canvas { border: 1px solid black; }
