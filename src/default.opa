/**
 * Game grid
 * 
 * 
 * 1: Normal food
 * 2: Special food (TODO)
 * 3: Ghost prison - There must be at least one
      - Best if walled or in a corner
 * 4: Ghost start point - There must be at least one
 * 5: Teleport - Moving the player at one end of the line will
 *    teleport it at the other end - Ghosts can't teleport.
 * 8: Wall
 */

grid = [
  [1,1,1,1,1,1,1,1,1,1,1,1,8,8,1,1,1,1,1,1,1,1,1,1,1,1],
  [2,8,8,8,8,1,8,8,8,8,8,1,8,8,1,8,8,8,8,8,1,8,8,8,8,2],
  [1,8,8,8,8,1,8,8,8,8,8,1,8,8,1,8,8,8,8,8,1,8,8,8,8,1],
  [1,8,8,8,8,1,8,8,8,8,8,1,8,8,1,8,8,8,8,8,1,8,8,8,8,1],
  [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
  [1,8,8,8,8,1,8,8,1,8,8,8,8,8,8,8,8,1,8,8,1,8,8,8,8,1],
  [1,8,8,8,8,1,8,8,1,8,8,8,8,8,8,8,8,1,8,8,1,8,8,8,8,1],
  [1,1,1,1,1,1,8,8,1,1,1,1,8,8,1,1,1,1,8,8,1,1,1,1,1,1],
  [8,8,8,8,8,1,8,8,8,8,8,0,8,8,0,8,8,8,8,8,1,8,8,8,8,8],
  [8,8,8,8,8,1,8,8,8,8,8,0,8,8,0,8,8,8,8,8,1,8,8,8,8,8],
  [8,8,8,8,8,1,8,8,0,0,0,0,0,0,0,0,0,0,8,8,1,8,8,8,8,8],
  [8,8,8,8,8,1,8,8,0,8,8,8,4,4,8,8,8,0,8,8,1,8,8,8,8,8],
  [8,8,8,8,8,1,8,8,0,8,0,0,8,8,0,0,8,0,8,8,1,8,8,8,8,8],
  [5,0,0,0,0,1,0,0,0,8,3,3,0,0,3,3,8,0,0,0,1,0,0,0,0,5],
  [8,8,8,8,8,1,8,8,0,8,3,3,3,3,3,3,8,0,8,8,1,8,8,8,8,8],
  [8,8,8,8,8,1,8,8,0,8,8,8,8,8,8,8,8,0,8,8,1,8,8,8,8,8],
  [8,8,8,8,8,1,8,8,0,0,0,0,0,0,0,0,0,0,8,8,1,8,8,8,8,8],
  [8,8,8,8,8,1,8,8,0,8,8,8,8,8,8,8,8,0,8,8,1,8,8,8,8,8],
  [8,8,8,8,8,1,8,8,0,8,8,8,8,8,8,8,8,0,8,8,1,8,8,8,8,8],
  [1,1,1,1,1,1,1,1,1,1,1,1,8,8,1,1,1,1,1,1,1,1,1,1,1,1],
  [1,8,8,8,8,1,8,8,8,8,8,1,8,8,1,8,8,8,8,8,1,8,8,8,8,1],
  [2,8,8,8,8,1,8,8,8,8,8,1,8,8,1,8,8,8,8,8,1,8,8,8,8,2],
  [1,1,1,8,8,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,8,8,1,1,1],
  [8,8,1,8,8,1,8,8,1,8,8,8,8,8,8,8,8,1,8,8,1,8,8,1,8,8],
  [8,8,1,8,8,1,8,8,1,8,8,8,8,8,8,8,8,1,8,8,1,8,8,1,8,8],
  [1,1,1,1,1,1,8,8,1,1,1,1,8,8,1,1,1,1,8,8,1,1,1,1,1,1],
  [1,8,8,8,8,8,8,8,8,8,8,1,8,8,1,8,8,8,8,8,8,8,8,8,8,1],
  [1,8,8,8,8,8,8,8,8,8,8,1,8,8,1,8,8,8,8,8,8,8,8,8,8,1],
  [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
]

Default = {{

  @private get_grid_nums(n) : set(Base.pos) =
    List.foldi(
      y, l, acc ->
        List.foldi(
          x, v, acc ->
            if v == n then Set.add(~{x y}, acc)
            else acc,
          l, acc),
      grid, Set.empty:set(Base.pos))

  walls = get_grid_nums(8)
  ghost_prison = get_grid_nums(3)
  ghost_start = get_grid_nums(4)

  food =
    normal = get_grid_nums(1)
    steroids = get_grid_nums(2)
    aux(set, t, acc) =
      Set.fold(
        p, acc -> Map.add(p, t, acc),
        set, acc)
    aux(normal, {normal}, Map.empty:map(Base.pos, Food.t))
    |> aux(steroids, {steroids}, _)

  teleports =
    elts =
      get_grid_nums(5)
      |> Set.fold(
        ~{x y}, acc -> [{line=y}|[{column=x}|acc]],
        _, [])
      |> List.sort
    if elts == [] then []
    else
      List.fold(
        e, (prev, acc) ->
          if e == prev then (e, [e|acc])
          else (e, acc),
        List.tail(elts), (List.head(elts), []))
      |> _.f2

  pacman = {
    base       = Base.make(13, 16, {right}, 10)
    next_dir   = {right}
    mouth_step = 0
    mouth_incr = 1
    mouth_steps = 10
  } : Pacman.t

  @private make_ghost(ai, prison, color, eye_color) =
  ~{x y} = Set.random_get(ghost_prison) |> Option.get
  { ~ai ~color ~eye_color
    base      = Base.make(x, y, {up}, 11)
    prison    = some(prison)
    eye_step  = 0
    eye_steps = 32
  } : Ghost.t

  ghosts = [
    ("g1", make_ghost({dumb}, 60, Color.orange, Color.crimson)),
    ("g2", make_ghost({guard}, 200, Color.darkred, Color.gold)),
    ("g3", make_ghost({dumb}, 400, Color.purple, Color.silver)),
    ("g4", make_ghost({guard}, 600, Color.green, Color.navy)),
  ] : list((string,Ghost.t))

}}
