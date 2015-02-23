
{graphics: g} = love

import WaterEmitter, DirtEmitter from require "particles"

class Object extends Entity
  lazy sprite: => Spriter "images/tile.png", 16, 16

  w: 16
  h: 16

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
    @sprite\draw "48,16,16,16", @x, @y

class WateringCan extends Object
  name: "watering can"

  use: (player, world) =>
    print "using watering can"
    if tile = player\active_tile!
      world.particles\add WaterEmitter tile, world
      tile_state = world.ground_tiles[tile]
      return unless tile_state
      tile_state.wet = true

  draw: =>
    @sprite\draw "48,16,16,16", @x, @y

class Hoe extends Object
  name: "hoe"

  use: (player, world) =>
    print "using hoe"
    if tile = player\active_tile!
      world.particles\add DirtEmitter tile, world
      tile_state = world.ground_tiles[tile]
      return unless tile_state
      tile_state.tilled = true

  draw: =>
    @sprite\draw "64,16,16,16", @x, @y

{ :Object, :WateringCan, :Hoe }

