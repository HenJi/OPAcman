@client Base = {{

  Dir = {{

    facing_angle(dir:Base.direction) =
      match dir with
      | {up}    | {still_up}    -> -Math.PI/2.
      | {down}  | {still_down}  -> Math.PI/2.
      | {left}  | {still_left}  -> Math.PI
      | {right} | {still_right} -> 0.

    deltas(dir:Base.direction) =
      match dir with
      | {up}    -> (0, -1)
      | {down}  -> (0, 1)
      | {left}  -> (-1, 0)
      | {right} -> (1, 0)
      | _ -> (0, 0)

    back(dir:Base.direction):Base.direction =
      match dir with
      | {up}    -> {down}
      | {down}  -> {up}
      | {left}  -> {right}
      | {right} -> {left}
      | x -> x

    is_still(dir:Base.direction) =
      match dir with
      | {still_up}   | {still_down}
      | {still_left} | {still_right} -> true
      | _ -> false

    get_still(dir:Base.direction) =
      match dir with
      | {up}    -> {still_up}
      | {down}  -> {still_down}
      | {left}  -> {still_left}
      | {right} -> {still_right}
      | x -> x

  }}

  @both make(x, y, dir, max_steps) = {
    pos = ~{x y}
    cur_step = 0
    ~dir ~max_steps
  }

  center(b:Base.t) =
    w = base_size
    d = (w*b.cur_step) / b.max_steps
    (dx, dy) = Dir.deltas(b.dir)
    (1+w/2+w*b.pos.x+d*dx,
     1+w/2+w*b.pos.y+d*dy)

}}
