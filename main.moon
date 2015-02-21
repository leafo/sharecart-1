
require "lovekit.all"
{graphics: g} = love

export DEBUG = false

import Game from require "game"

load_font = (img, chars)->
  font_image = imgfy img
  g.newImageFont font_image.tex, chars

love.load = ->
  fonts = {
    default: load_font "images/font.png",
      [[ abcdefghijklmnopqrstuvwxyz-1234567890!.,:;'"?$&]]
  }

  g.setFont fonts.default
  g.setBackgroundColor 10, 10, 10

  export CONTROLLER = Controller GAME_CONFIG.keys, "auto"
  export DISPATCHER = Dispatcher Game!
  DISPATCHER.default_transition = FadeTransition
  DISPATCHER\bind love