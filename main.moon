
require "lovekit.reloader"
require "lovekit.all"

{graphics: g} = love

sharecart = require "sharecart"

export DEBUG = false

export C = {
  skin: {220, 198, 124}
  shadow: {144, 144, 152}
  stone: {164, 218, 196}
  grass: {60, 136, 68}
  grass_dark: {28, 70, 36}
  grass_light: {164, 218, 196} -- aka stone

  dirt: {148,74,28}
  dirt_dark: {95, 57, 31}

  wood: {148, 146, 76}
  wood_light: {220, 198, 124}
  wood_dark: {73, 84, 65}
}

import Game from require "game"

load_font = (img, chars) ->
  font_image = imgfy img
  g.newImageFont font_image.tex, chars

love.load = ->
  fonts = {
    default: load_font "images/font.png",
      [[ abcdefghijklmnopqrstuvwxyz-1234567890!.,:;'"?$&]]
  }

  export SHARECART = assert sharecart.love_load(love, args),
    "could not find valid save"

  SHARECART.PlayerName = "leafo buttthrob"

  g.setFont fonts.default
  g.setBackgroundColor 10, 10, 10

  export CONTROLLER = Controller GAME_CONFIG.keys, "auto"
  export DISPATCHER = Dispatcher Game!
  DISPATCHER.default_transition = FadeTransition
  DISPATCHER\bind love
