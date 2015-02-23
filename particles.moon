{graphics: g} = love

class WaterParticle extends PixelParticle
  life: 0.4
  new: (...) =>
    super ...
    color = C.water

    color = pick_one C.water, C.water_light
    @r,@g,@b = unpack color
    @size = pick_one 2,3,4,5

    @vel = Vec2d 0, 20
    @accel = Vec2d 0, 50

  draw: =>
    g.push!

    g.translate @x, @y
    s = pop_in @p!, 0.1, 2
    g.scale s, s
    g.translate -@x, -@y

    super!
    g.pop!

class DirtParticle extends PixelParticle
  life: 0.4
  new: (...) =>
    super ...
    color = pick_one C.skin, C.dirt_darker
    @r,@g,@b = unpack color
    @size = pick_one 2,3,4,5

    @vel = Vec2d(0, -100)\random_heading!
    @accel = Vec2d 0, 300

  draw: =>
    g.push!

    g.translate @x, @y
    s = pop_in @p!, 0.1, 2
    g.scale s, s
    g.translate -@x, -@y

    super!
    g.pop!


class WaterEmitter extends Emitter
  count: 20
  duration: 0.4
  new: (@box, ...) =>
    super ...

  make_particle: =>
    x = @box.x + love.math.random! * @box.w
    y = @box.y + love.math.random! * @box.h
    WaterParticle x, y - @box.h

  draw: (...) =>
    COLOR\push C.water
    -- g.rectangle "line", @box\unpack!
    COLOR\pop!
    super ...

class DirtEmitter extends Emitter
  count: 20
  duration: 0.2
  new: (@box, ...) =>
    super ...

  make_particle: =>
    x = @box.x + love.math.random! * @box.w
    y = @box.y + love.math.random! * @box.h
    DirtParticle x, y

  draw: (...) =>
    COLOR\push C.dirt_darker
    -- g.rectangle "line", @box\unpack!
    COLOR\pop!
    super ...


{ :WaterEmitter, :DirtEmitter }
