
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

class Game
  new: =>
    @viewport = EffectViewport scale: GAME_CONFIG.scale
    @entities = EntityList!
    @entities\add Player 100, 100
    @entities\add Object 130, 130, 20, 16

    @entity_grid = UniformGrid!

    @sheet = TileSheet!

  draw: =>
    @viewport\apply!
    g.print "hello world", 10, 10

    @entities\draw!

    g.push!
    g.translate 20, 20
    g.scale 4, 4
    g.draw @sheet.canvas, 0, 0
    g.pop!

    @viewport\pop!


  update: (dt) =>
    @entities\update dt, @

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

