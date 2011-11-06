type Base.direction =
    {up} / {down} / {left} / {right}
  / {still_up} / {still_down}
  / {still_left} / {still_right}

type Base.pos = {
  x : int
  y : int
}

type Base.teleports =
    { line : int }
  / { column : int }

type Base.t = {
  pos       : Base.pos
  dir       : Base.direction
  cur_step  : int /* Current step */
  max_steps : int /* Max steps in the move (determines speed) */
}

type Pacman.t = {
  base        : Base.t
  next_dir    : Base.direction
  mouth_step  : int
  mouth_incr  : int
  mouth_steps : int
}

type Ghost.ai =
    {dumb}
  / {guard}

type Ghost.t = {
  ai        : Ghost.ai
  base      : Base.t
  /* Number of cycles in prison
     NOTE: moving takes 10 cycles */
  prison    : option(int)
  color     : color
  eye_color : color
  eye_step  : int
  eye_steps : int
}

type Food.t =
    {normal}
  / {steroids}

type Game.state =
    {game_start}
  / {running}
  / {pause}
  / {game_over}

type Game.status = {
  state       : Game.state
  pacman      : Pacman.t
  ghosts      : list(Ghost.t)
  food        : map(Base.pos, Food.t)
  score       : int
  lives       : int
  on_steroids : option(int) /* Number of cycles on steroids */
}
