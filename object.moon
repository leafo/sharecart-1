
{graphics: g} = love

import WaterEmitter, DirtEmitter from require "particles"

class Object extends Entity
  color: C.stone
  solid: true
  held_by: nil

  update: (...) =>
    if o = @held_by
      @move_center o\head_pos!
      return true

    super ...
    true

  pickup: (thing, world) =>
    world\remove @

    @held_by = thing
    thing.holding = @

  drop: (thing, world) =>
    @held_by = nil
    thing.holding = nil
    world\add @

  __tostring: => "<Object #{Box.__tostring @}>"

  draw: =>
    super!
    g.print @@__name\lower!, @x, @y

class WateringCan extends Object
  name: "watering can"

  use: (player, world) =>
    print "using watering can"
    if tile = player\active_tile!
      world.particles\add WaterEmitter tile, world

class Hoe extends Object
  name: "hoe"

  use: (player, world) =>
    print "using hoe"
    if tile = player\active_tile!
      world.particles\add DirtEmitter tile, world

{ :Object, :WateringCan, :Hoe }

