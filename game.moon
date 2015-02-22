
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

class World
  new: (@game, map_name) =>
    @viewport = EffectViewport scale: GAME_CONFIG.scale
    @entities = DrawList!

    -- @entities\add Object 130, 130, 20, 16
    @entity_grid = UniformGrid!
    @sheet = TileSheet!
    @spawns = {}

    map_rng = love.math.newRandomGenerator 666
    @map = TileMap\from_tiled map_name, {
      object: (o) ->
        switch o.name
          when "start"
            @spawns[o.properties.source or "default"] = {
              o.x
              o.y
            }
          when "transport"
            world_name = assert o.properties.world, "transport has no world"
            @entities\add Transport world_name, o.x, o.y, o.width, o.height

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

  add_player: (player, source="default") =>
    sx, sy = unpack @spawns[source]
    assert sx, "missing spawn"
    @player = player
    @player.x = sx
    @player.y = sy
    @entities\add player

  remove_player: =>
    @entities\remove @player

  draw: =>
    g.setCanvas @screen_canvas
    @screen_canvas\clear 10, 10, 10

    @viewport\apply!

    @map\draw @viewport, 1, 1
    @entities\draw!
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

    if @player
      @viewport\center_on @player, @map\to_box!, dt

    @viewport\update dt

    @entity_grid\clear!

    for e in *@entities
      continue unless e.w -- is a box
      continue if e.held_by
      @entity_grid\add e

    if @player
      for other in *@entity_grid\get_touching @player
        if other.is_transport
          @game\goto_world other.target

  collides: (thing) =>
    for other in *@entity_grid\get_touching thing
      if other.solid
        return true

    if @map\collides thing
      return true

    false

class Game
  new: =>
    @worlds_by_name = {
      farm: World @, "maps.map"
      home: World @, "maps.home"
    }

    @player = Player 0,0

  goto_world: (name) =>
    world = assert @worlds_by_name[name],
      "invalid world"

    if @current_world
      @current_world\remove_player @player

    world\add_player @player
    DISPATCHER\replace world

  update: (dt) =>
    @goto_world "farm"
    true

  draw: =>

{ :Game, :World }

