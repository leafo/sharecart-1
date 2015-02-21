
export GAME_CONFIG = {
  scale: 3
  keys: {
    confirm: { "x", " ", joystick: 1}
    cancel: { "c", joystick: 2 }

    shoot: { "x", " ", joystick: 2 }
    upgrade: { "c", "return", joystick: 1 }

    up: "up"
    down: "down"
    left: "left"
    right: "right"
  }
}

love.conf = (t) ->
  t.window.width = 210 * GAME_CONFIG.scale
  t.window.height = 136 * GAME_CONFIG.scale

  t.title = "teafart"
  t.author = "leafo"
