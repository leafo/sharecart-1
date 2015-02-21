
{graphics: g} = love

import Player from require "player"
import Object from require "object"

class Game
  new: =>
    @viewport = EffectViewport scale: GAME_CONFIG.scale
    @entities = EntityList!
    @entities\add Player 100, 100
    @entities\add Object 130, 130, 20, 16

    @entity_grid = UniformGrid!

  draw: =>
    @viewport\apply!
    g.print "hello world", 10, 10

    @entities\draw!
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

