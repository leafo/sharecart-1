
{graphics: g} = love

import Player from require "player"
import
  GrassGenerator
  DirtGenerator
  WoodGenerator
  TileSheet
  from require "tiles"

objects = require "object"

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
  new: (@game, @map_name) =>
    @viewport = EffectViewport scale: GAME_CONFIG.scale
    @entities = DrawList!

    @entity_grid = UniformGrid!
    @sheet = TileSheet!
    @spawns = {}

    map_rng = love.math.newRandomGenerator 666
    @map = TileMap\from_tiled @map_name, {
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

    @map\draw @viewport, 1, 1
    @entities\draw_sorted!
    @map\draw @viewport, 2, 2

    @viewport\pop!

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

  remove: (...) => @entities\remove ...
  add: (...) => @entities\add ...

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

    @current_world = world
    world\add_player @player
    DISPATCHER\replace world

  update: (dt) =>
    @goto_world "farm"
    true

  draw: =>

{ :Game, :World }

