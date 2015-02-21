
{graphics: g} = love

import Player from require "player"

class Game
  new: =>
    @viewport = EffectViewport scale: GAME_CONFIG.scale
    @entities = EntityList!
    @entities\add Player 100, 100

  draw: =>
    @viewport\apply!
    g.print "hello world", 10, 10

    @entities\draw!

    @viewport\pop!

  update: (dt) =>
    @entities\update dt, @


{ :Game }

