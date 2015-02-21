class Player extends Entity
  color: {255, 255, 255}
  is_player: true
  speed: 120

  w: 24
  h: 32

  new: (@x, @y) =>

  update: (dt, @world) =>
    dir = CONTROLLER\movement_vector! * dt * @speed
    @move unpack dir
    true

{ :Player }

