
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

class Transport extends Box
  solid: false
  is_transport: true

  new: (@target, ...) =>
    super ...

  draw: =>
    g.rectangle "line", @unpack!

  update: (dt) =>
    true


class Game
  new: =>
    @viewport = EffectViewport scale: GAME_CONFIG.scale
    @entities = EntityList!

    @player = Player 0,0
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
          when "transport"
            map = assert o.properties.map, "transport has no map"
            @entities\add Transport map, o.x, o.y, o.width, o.height

      tile: (t) ->
        p = math.abs map_rng\randomNormal!
        offset = math.floor math.min 3, p
        t.tid = t.tid * TileSheet.w + offset
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
    @viewport\center_on @player

    @map\draw @viewport, 1, 1

    -- g.print "hello world", 10, 10

    @entities\draw!

    -- g.push!
    -- g.translate 20, 20
    -- g.draw @sheet.canvas, -80, -80
    -- g.pop!

    @map\draw @viewport, 2, 2

    @viewport\pop!

    -- COLOR\push 0,0,0, (math.sin(love.timer.getTime! * 2) + 1) / 2 * 255
    -- g.rectangle "fill", 0, 0, g.getWidth!, g.getHeight!
    -- COLOR\pop!

    g.setCanvas!

    @lut\render ->
      g.draw @screen_canvas

  update: (dt) =>
    @entities\update dt, @
    @map\update dt
    @viewport\update dt

    @entity_grid\clear!

    for e in *@entities
      continue unless e.w -- is a box
      continue if e.held_by
      @entity_grid\add e

    for other in *@entity_grid\get_touching @player
      if other.is_transport
        print "transport", other.target


  collides: (thing) =>
    for other in *@entity_grid\get_touching thing
      if other.solid
        return true

    if @map\collides thing
      return true

    false

{ :Game }

