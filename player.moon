
-- Properties
-- holding: object being held
-- primary_direction: vector of last faced direction
-- grab_box: the hitbox for the grab/activate zone
class Player extends Entity
  color: {255, 255, 255}
  is_player: true
  speed: 120
  solid: true

  w: 24
  h: 16

  feet_offset_x: 12
  feet_offset_y: 8

  new: (@x=0, @y=0) =>

  looking_at: =>
    cx, cy = @center!

    if @primary_direction
      cx += @primary_direction[1] * 10
      cy += @primary_direction[2] * 10


    cx, cy

  update: (dt, @world) =>
    dir = CONTROLLER\movement_vector! * dt * @speed
    unless dir\is_zero!
      @primary_direction = dir\primary_direction!

    dx, dy = unpack dir

    @fit_move dx, dy, @world

    if @holding
      @holding\update dt

    if @primary_direction
      @grab_box or= Box 0,0, 25, 20
      offset = Vec2d(@feet_pos!) + @primary_direction * 10
      @grab_box\move_center unpack offset

    if CONTROLLER\downed "pickup"
      unless @try_pickup!
        @try_drop!

    if CONTROLLER\downed "use"
      if @holding
        @holding\use @, @world

    true

  feet_pos: =>
    @x + @feet_offset_x, @y + @feet_offset_y

  move_feet: (x,y) =>
    @x = x - @feet_offset_x
    @y = y - @feet_offset_y

  head_pos: =>
    @x + @w / 2, @y - 10

  try_pickup: =>
    return if @holding
    return unless @grab_box
    for obj in *@world.entity_grid\get_touching @grab_box
      if obj.pickup
        obj\pickup @, @world
        return true

    false

  try_drop: =>
    return unless @holding
    return unless @primary_direction
    return unless @grab_box

    ox, oy = @holding\center!
    cx, cy = @grab_box\center!

    @holding\move_center math.floor(cx), math.floor(cy)
    print "Trying drop"
    for i=1,20
      touches = @world\collides @holding

      unless touches
        @holding\drop @, @world
        return true

      @holding\move unpack @primary_direction

    @holding\move_center ox, oy
    return false

  draw: =>
    sprite = Box(0, 0, 24, 32)
    sprite\set_pos @x, @y - 32 + @h
    sprite\draw C.skin

    super { 255,255,255, 50 }

    fx, fy = @feet_pos!
    box = Box(0, 0, 3, 3)\move_center fx, fy
    box\draw C.grass

    if @grab_box
      COLOR\pusha 100
      @grab_box\draw C.dirt
      COLOR\pop!

    if @holding
      @holding\draw!

  find_tiles: =>
    return unless @world
    fx, fy = @feet_pos!
    cell_size = @world.map.cell_size

    tx = math.floor(fx / cell_size)
    ty = math.floor(fx / cell_size)

    ti = @world.map\to_i tx, ty
    @world.map\default_layer![ti]

  __tostring: => "<Player>"

{ :Player }

