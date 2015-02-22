
{graphics: g} = love

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
  use: (player, world) =>
    print "using watering can"

class Hoe extends Object
  use: (player, world) =>
    print "using watering hoe"

{ :Object, :WateringCan, :Hoe }

