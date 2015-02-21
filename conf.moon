
export GAME_CONFIG = {
  scale: 2
  keys: {
    confirm: { "x", " " }
    cancel: { "c" }

    shoot: { "x", " " }
    upgrade: { "c", "return" }

    up: "up"
    down: "down"
    left: "left"
    right: "right"
  }
}

love.conf = (t) ->
  t.window.width = 420 * GAME_CONFIG.scale
  t.window.height = 272 * GAME_CONFIG.scale

  t.title = "teafart"
  t.author = "leafo"
