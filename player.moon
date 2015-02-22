
-- Properties
-- holding: object being held
-- primary_direction: vector of last faced direction
-- grab_box: the hitbox for the grab/activate zone
class Player extends Entity
  color: {255, 255, 255}
  is_player: true
  speed: 120
  solid: true

  lazy sprite: => Spriter "images/player.png", 24, 32


  w: 18
  h: 10

  feet_offset_x: 8
  feet_offset_y: 6

  ox: -3
  oy: -23

  new: (@x=0, @y=0) =>
    with @sprite
      @anim = StateAnim "stand_down", {
        walk_up: \seq {
          5, 8, 11, 2
        }, 0.15

        walk_down: \seq {
          3, 6, 9, 0
        }, 0.15

        walk_left: \seq {
          4, 7, 10, 1
        }, 0.15

        walk_right: \seq {
          4, 7, 10, 1
        }, 0.15, true

        stand_up: \seq { 2 }
        stand_down: \seq { 0 }
        stand_left: \seq { 1 }
        stand_right: \seq { 1 }, nil, true
      }

  looking_at: =>
    cx, cy = @center!

    if @primary_direction
      cx += @primary_direction[1] * 10
      cy += @primary_direction[2] * 10


    cx, cy

  update: (dt, @world) =>
    dir = CONTROLLER\movement_vector! * dt * @speed
    if dir\is_zero!
      @state = "stand"
    else
      @state = "walk"
      @primary_direction = dir\primary_direction!

    dx, dy = unpack dir

    @anim\update dt

    if @primary_direction
      @facing = @primary_direction\direction_name!
      @anim\set_state "#{@state}_#{@facing}"

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
    @anim\draw @x + @ox, @y + @oy

    -- if @grab_box
    --   COLOR\pusha 100
    --   @grab_box\draw C.dirt
    --   COLOR\pop!

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

