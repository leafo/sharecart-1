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
    @move unpack dir
    unless dir\is_zero!
      @primary_direction = dir\primary_direction!

    true

  feet_pos: =>
    @x + @feet_offset_x, @y + @feet_offset_y

  draw: =>
    sprite = Box(0, 0, 24, 32)
    sprite\set_pos @x, @y - 32 + @h
    sprite\draw {144, 144, 152}

    super {255,255,255, 50}

    fx, fy = @feet_pos!
    box = Box(0, 0, 3, 3)\move_center fx, fy
    box\draw {100, 255, 100, 200}

    if @primary_direction
      offset = Vec2d(fx, fy) + @primary_direction * 10
      grab_zone = Box(0,0, 25, 20)\move_center unpack offset
      grab_zone\draw {255, 100, 100, 100}


{ :Player }

