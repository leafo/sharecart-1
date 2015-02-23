
{graphics: g} = love

import Player from require "player"
import
  GrassGenerator
  DirtGenerator
  WoodGenerator
  TileSheet
  from require "tiles"

import Hud from require "hud"

objects = require "object"

import rshift, lshift, band, bxor from require "bit"

class Dirt extends Tile
  dirt: true

class Transport extends Box
  solid: false
  is_transport: true

  new: (@target, ...) =>
    super ...

  draw: =>
    -- g.rectangle "line", @unpack!

  update: (dt) =>
    true

class GameMap extends TileMap
  default_layer: =>
    @layers[1]

class World
  new: (@game, @map_name) =>
    @viewport = EffectViewport scale: GAME_CONFIG.scale
    @entities = DrawList!
    @particles = DrawList!

    @entity_grid = UniformGrid!
    @sheet = TileSheet!
    @spawns = {}

    map_rng = love.math.newRandomGenerator 666
    @map = GameMap\from_tiled @map_name, {
      object: (o) ->
        obox = Box o.x, o.y, o.width, o.height

        switch o.name
          when "start"
            @spawns[o.properties.source or "default"] = { obox\center! }
          when "transport"
            world_name = assert o.properties.world, "transport has no world"
            @entities\add Transport world_name, o.x, o.y, o.width, o.height
          when "object"
            obj = assert objects[o.properties.type],
              "failed to find object #{o.properties.type}"
            @entities\add obj obox\center!

      tile: (t) ->
        p = math.abs map_rng\randomNormal!
        offset = math.floor math.min 3, p
        t.type = Dirt if t.tid == 1
        t.tid = t.tid * TileSheet.w + offset
        t

    }

    @map.sprite = @sheet\spriter!

  add_player: (player, source="default") =>
    sx, sy = unpack @spawns[source]
    assert sx, "missing spawn"
    @player = player
    @player\move_feet sx, sy
    @entities\add player

  remove_player: =>
    @entities\remove @player

  draw: =>
    @viewport\apply!
    @draw_inside!
    @viewport\pop!
    @game.hud\draw!

  draw_inside: =>
    @map\draw @viewport, 1, 1
    @draw_inside_below!
    @entities\draw_sorted!
    @particles\draw!
    @map\draw @viewport, 2, 2

  draw_inside_below: =>

  update: (dt) =>
    @entities\update dt, @
    @particles\update dt, @
    @map\update dt
    @game.hud\update dt

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

  remove: (...) => @entities\remove ...
  add: (...) => @entities\add ...

class OutsideWorld extends World
  new: (...) =>
    super ...
    @night = imgfy "images/night.png"

    @ground_tiles = {}
    @ground_grid = UniformGrid 32
    @all_tiles = for _, t in pairs @map\default_layer!
      if t.dirt
        @ground_tiles[t] = {}
        @ground_grid\add t
        t
      else
        continue

    @read_from_cart @all_tiles


    @seq = Sequence ->
      wait 2
      @save_to_cart @all_tiles
      again!


  read_from_cart: (tiles, key="Misc0") =>
    stride = 4
    num = SHARECART[key] or 0
    print "Reading tiles from", num

    for t in *tiles
      k = num % stride
      num = math.floor num / 2
      @ground_tiles[t] = switch num
        when 0
          {}
        when 1
          {wet: true}
        when 2
          {tilled: true}
        when 3
          {wet: true, tilled: true}

  update: (dt) =>
    super dt
    @seq\update dt

    if CONTROLLER\downed "save"
      @save_to_cart @all_tiles

  save_to_cart: (tiles, key="Misc0") =>
    number = 0
    for i, t in ipairs tiles
      state = @ground_tiles[t]
      if state.wet
        bit = i % 16
        number = bxor number, lshift 1, bit

    SHARECART.Misc0 = number

    number = 0
    for i, t in ipairs tiles
      state = @ground_tiles[t]
      if state.tilled
        bit = i % 16
        number = bxor number, lshift 1, bit

    SHARECART.Misc1 = number
    print "Saved:", "Misc0", SHARECART.Misc0, "Misc1", SHARECART.Misc1

  draw_inside_below: =>
    for t, v in pairs @ground_tiles
      offset = t.tid % 7

      sheet_tid = if v.wet and not v.tilled
        -- wet
        @sheet\row_tid 5
      elseif v.tilled and not v.wet
        -- tilled
        @sheet\row_tid 6
      elseif v.tilled and v.wet
        -- both
        @sheet\row_tid 7

      if sheet_tid
        @map.sprite\draw sheet_tid + offset, t.x, t.y

  draw_inside: =>
    super!

    @active_tile = nil
    if box = @player and @player.grab_box
      if tiles = @ground_grid\get_touching_pt box\center!
        @active_tile = unpack tiles

    if @active_tile
      g.rectangle "line", @active_tile\unpack!

    if @player
      p = @game.hud\night_darkness!
      if p > 0
        cx, cy = @player\center!

        nx = cx - @night\width! / 2
        ny = cy - @night\height! / 2

        nx = math.min @viewport.x, nx
        ny = math.min @viewport.y, ny

        nx = math.max nx, @viewport.w - @night\width!
        ny = math.max ny, @viewport.h - @night\height!

        COLOR\pusha p * 255
        @night\draw nx, ny
        COLOR\pop!

class Game
  new: =>
    @hud = Hud @
    @worlds_by_name = {
      farm: OutsideWorld @, "maps.map"
      home: World @, "maps.home"
    }

    @player = Player 0,0

  goto_world: (name) =>
    world = assert @worlds_by_name[name],
      "invalid world"

    if @current_world
      @current_world\remove_player @player
      @current_world.player = nil

    @current_world = world
    world\add_player @player
    DISPATCHER\replace world

  update: (dt) =>
    @goto_world "farm"
    true

  draw: =>

{ :Game, :World }

