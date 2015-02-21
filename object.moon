
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

  pickup: (obj) =>
    @held_by = obj
    obj.holding = @

  __tostring: => "<Object #{Box.__tostring @}>"

{ :Object }

