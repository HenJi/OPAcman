type Base.direction =
    {up} / {down} / {left} / {right}
  / {still_up} / {still_down}
  / {still_left} / {still_right}

type Base.pos = {
  x : int
  y : int
}

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
  color     : color
  eye_color : color
  eye_step  : int
  eye_steps : int
}

type Game.status = {
  pacman      : Pacman.t
  ghosts      : list(Ghost.t)
  food        : set(Base.pos)
  score       : int
}
