import stdlib.web.canvas

/* Config */

fps = 60
base_size = 32
grid_width  = List.length(List.head(grid))
grid_heigth = List.length(grid)
info_width = 250

food_points = 10
steroid_points = 100
steroid_len = 6*fps /* frames */
clear_bonus = 500
life_points = 2500

pacman_speed = 10
pacman_speed_on_steroids = 8
ghosts_speed = 11

/* Defaults */

default_game = {
  state       = {game_start}
  pacman      = Default.pacman
  ghosts      = Default.ghosts
  food        = Default.food
  score       = 0
  lives       = 3
  on_steroids = none
  scores      = []
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

check_collision(g:Game.status):Game.status =
  pc = Base.center(g.pacman.base)
  has_collision = List.fold(
    (gid, ghost), res ->
      if Option.is_some(res) then res
      else
        gc = Base.center(ghost.base)
        x = gc.f1 - pc.f1
        y = gc.f2 - pc.f2
        d = Math.sqrt_i(x*x+y*y)
        if d < 2*base_size/3 then some(gid)
        else res,
    g.ghosts, none)
  if Option.is_none(has_collision) then g
  else
    match g.on_steroids with
    | {some=s} ->
      cid = Option.get(has_collision)
      on_steroids = some({s with combo=s.combo+1})
      ghosts = List.map(
        (gid, ghost) ->
          if gid != cid then (gid, ghost)
          else
            ~{x y} =
              Set.random_get(Default.ghost_prison)
              |> Option.get
            base = Base.make(x, y, {up}, 11)
            prison = some(100)
            (gid, {ghost with ~base ~prison}),
        g.ghosts)
      score = g.score + (match s.combo with
        | 0 ->  100 | 1 ->  200 | 3 ->  500 | _ -> 1000)
      lives = g.lives + (score/life_points - g.score/life_points)
      {g with ~ghosts ~score ~lives ~on_steroids}
    | {none} ->
      if g.lives < 2 then
        scores = Scores.get()
        cur_min =
          if scores == [] then 0
          else List.rev(scores) |> List.head |> _.f1
        state =
          if g.score > cur_min then {score=""}
          else {game_over}
        {g with ~scores ~state
          lives = 0}
      else
        {default_game with
          food = g.food
          score = g.score
          lives = g.lives-1
          scores = Scores.get()}

@client clean_frame(ctx:Canvas.context) =
  Canvas.clear_rect(
    ctx, 0, 0,
    2+base_size*grid_width,
    2+base_size*grid_heigth)

@client blink(f) =
  t = Date.now() |> Date.in_milliseconds
  t = t / 100
  t = t - (t/10)*10
  if t > 3 then f()

@client next_frame(ctx:Canvas.context)() =
  draw_board(g) =
    do clean_frame(ctx)
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
    | {score=name} ->
      do blink(->Info.draw_score_entry(ctx, name))
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

@client key_to_dir(code:int) =
  match code with
  | 38 | 87 | 90 -> some({dir_up})
  | 40 | 83 -> some({dir_down})
  | 37 | 65 | 81 -> some({dir_left})
  | 39 | 68 -> some({dir_right})
  | _ -> none

@client keyfun(e) =
  g = game.get()
  p = g.pacman
  // do Dom.transform([#debug <- "{e.key_code}"])
  dir_key = key_to_dir(e.key_code ? -1)
  p = match (p.base.dir, dir_key) with
    | ({down}, {some={dir_up}}) ->
        {p with next_dir={up}
                base={p.base with dir={up}
                                  cur_step=-p.base.cur_step}}
    | (_, {some={dir_up}}) -> {p with next_dir={up}}

    | ({right}, {some={dir_left}}) ->
        {p with next_dir={left}
                base={p.base with dir={left}
                                  cur_step=-p.base.cur_step}}
    | (_, {some={dir_left}}) -> {p with next_dir={left}}

    | ({up}, {some={dir_down}}) ->
        {p with next_dir={down}
                base={p.base with dir={down}
                                  cur_step=-p.base.cur_step}}
    | (_, {some={dir_down}}) -> {p with next_dir={down}}

    | ({left}, {some={dir_right}}) ->
        {p with next_dir={right}
                base={p.base with dir={right}
                                  cur_step=-p.base.cur_step}}
    | (_, {some={dir_right}}) -> {p with next_dir={right}}

    | _ -> p
  g = match (g.state, e.key_code) with
    // r (reset if game over)
    | ({game_over}, {some=82}) ->
      { default_game with scores=Scores.get() }

    // any letter for high score
    | ({score=name}, {some=key}) ->
      if key == 13 then
        scores = Scores.add(name, g.score)
        {g with ~scores state={game_over}}
      else
        char_idx = key - 65
        new_char =
          if char_idx >= 0 && char_idx < 26 then
            String.get(char_idx, "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
          else ""
        ll = String.length(name)
        score =
          if key == 8 && ll != 0 then
            String.substring_unsafe(0, ll-1, name)
          else if new_char == "" then name
          else if ll < 3 then "{name}{new_char}"
          else name
        {g with state={~score}}

    // space (pause start)
    | ({running}, {some=32}) -> {g with state={pause}}

    // any direction or space to resume
    | ({pause}, {some=k}) ->
      if k == 32 || Option.is_some(dir_key) then
        {g with state={running} pacman=p}
      else g

    // any direction to start game
    | ({game_start}, {some=_}) ->
      if Option.is_some(dir_key) then
        {g with state={running} pacman=p}
      else g

    | _ -> {g with pacman=p}
  game.set(g)

@client init(scores) =
  do game.set({game.get() with ~scores})
  do match Canvas.get(#bg_holder) with
    | {none} -> void
    | {some=canvas} ->
      bg_ctx = Canvas.get_context_2d(canvas) |> Option.get
      Wall.draw(bg_ctx)
  match Canvas.get(#game_holder) with
  | {none} -> void
  | {some=canvas} ->
    ctx = Canvas.get_context_2d(canvas) |> Option.get
    t = Scheduler.make_timer(1000/fps, next_frame(ctx))
    _ = Dom.bind_with_options(Dom.select_document(), {keydown}, keyfun, [{prevent_default}])
    t.start()

body() =
  width = 2+base_size*grid_width+info_width
  height = 2+base_size*grid_heigth
  scores = Scores.get()
  <>
    <canvas id="bg_holder" width="{width}" height="{height}">
      You can't see canvas, upgrade your browser !
    </canvas>
    <canvas id="game_holder" width="{width}" height="{height}">
      You can't see canvas, upgrade your browser !
    </canvas>
    <div>
      <span id="info" onready={_ -> init(scores)}></span>
      <span id="debug"></span>
    </div>
  </>

server = one_page_server("OPAcman", body)

css = css
  canvas {
    border: 1px solid black;
    position: absolute;
  }
