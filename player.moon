class Player extends Entity
  color: {255, 255, 255}
  is_player: true
  speed: 120

  w: 24
  h: 16

  feet_offset_x: 12
  feet_offset_y: 8

  new: (@x, @y) =>

  update: (dt, @world) =>
    dir = CONTROLLER\movement_vector! * dt * @speed
    unless dir\is_zero!
      @primary_direction = dir\primary_direction!

    dx, dy = unpack dir
    @fit_move dx, dy, @world

    if @primary_direction
      @grab_box or= Box 0,0, 25, 20
      offset = Vec2d(@feet_pos!) + @primary_direction * 10
      @grab_box\move_center unpack offset

    if CONTROLLER\tapped "confirm"
      @try_pickup!

    true

  feet_pos: =>
    @x + @feet_offset_x, @y + @feet_offset_y

  head_pos: =>
    @x + @w / 2, @y - 10

  try_pickup: =>
    return unless @grab_box
    for obj in *@world.entity_grid\get_touching @grab_box
      if obj.pickup
        obj\pickup @
        break

  try_drop: =>
    return unless @holding
    print "drop it"

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

  __tostring: => "<Player>"

{ :Player }

