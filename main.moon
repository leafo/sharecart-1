
-- require "lovekit.reloader"
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
  dirt_darker: {50, 45, 35}

  wood: {148, 146, 76}
  wood_light: {220, 198, 124}
  wood_dark: {73, 84, 65}

  floor: {73, 84, 65}
  floor_light: {144, 144, 152}

  top: {95, 57, 31}
  top_light: {150,70,30}

  water_light: {108, 250, 220}
  water: {4, 147, 204}
}

import Game from require "game"
import LutShader from require "shaders"

class State extends Dispatcher
  default_transition: FadeTransition

  new: (...) =>
    super ...

    @screen_canvas = g.newCanvas!
    @screen_canvas\setFilter "nearest", "nearest"

    lut = imgfy "images/lut-restricted.png"
    @lut = LutShader lut.tex

  draw: =>
    g.setCanvas @screen_canvas
    @screen_canvas\clear 10, 10, 10

    super!

    g.setCanvas!

    @lut\render ->
      g.draw @screen_canvas


load_font = (img, chars) ->
  font_image = imgfy img
  g.newImageFont font_image.tex, chars

love.load = (args) ->
  fonts = {
    default: load_font "images/font.png",
      [[ abcdefghijklmnopqrstuvwxyz-1234567890!.,:;'"?$&]]
  }


  export SHARECART = {}
  pcall ->
    export SHARECART = assert sharecart.love_load(love, args),
      "could not find valid save"

  g.setFont fonts.default
  g.setBackgroundColor 10, 10, 10

  export CONTROLLER = Controller GAME_CONFIG.keys, "auto"
  export DISPATCHER = State Game!
  DISPATCHER\bind love
