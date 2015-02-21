
{graphics: g} = love

import Player from require "player"
import Object from require "object"
import
  GrassGenerator
  DirtGenerator
  WoodGenerator
  TileSheet
  from require "tiles"

import HList, VList from require "lovekit.ui"
import LutShader from require "shaders"

class Game
  new: =>
    @viewport = EffectViewport scale: GAME_CONFIG.scale
    @entities = EntityList!

    @player = Player 100, 100
    @entities\add @player
    @entities\add Object 130, 130, 20, 16

    @entity_grid = UniformGrid!

    @sheet = TileSheet!

    map_rng = love.math.newRandomGenerator 666
    @map = TileMap\from_tiled "maps.map", {
      object: (o) ->
        switch o.name
          when "start"
            @player.x = o.x
            @player.y = o.y

      tile: (t) ->
        p = math.abs map_rng\randomNormal!
        offset = math.floor math.min 3, p
        t.tid = offset * 4
        t

    }

    @map.sprite = @sheet\spriter!

    @screen_canvas = g.newCanvas!
    @screen_canvas\setFilter "nearest", "nearest"

    lut = imgfy "images/lut-restricted.png"
    @lut = LutShader lut.tex

  draw: =>
    g.setCanvas @screen_canvas
    @screen_canvas\clear 10, 10, 10

    @viewport\apply!
    @map\draw!

    @viewport\center_on @player

    g.print "hello world", 10, 10

    @entities\draw!

    g.push!
    g.translate 20, 20
    g.draw @sheet.canvas, -80, -80
    g.pop!

    -- COLOR\push 0,0,0, (math.sin(love.timer.getTime! * 2) + 1) / 2 * 255
    -- g.rectangle "fill", 0, 0, @viewport.w, @viewport.h
    -- COLOR\pop!

    g.draw imgfy("images/hi.png").tex

    @viewport\pop!
    g.setCanvas!

    @lut\render ->
      g.draw @screen_canvas

  update: (dt) =>
    @entities\update dt, @
    @map\update dt

    @entity_grid\clear!
    for e in *@entities
      continue unless e.w -- is a box
      continue if e.held_by
      @entity_grid\add e

  collides: (thing) =>
    for other in *@entity_grid\get_touching thing
      return true

    false

{ :Game }

